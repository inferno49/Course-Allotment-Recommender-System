jsoniq version "1.0";

module namespace ns = "http://DGSProject/DGSProject.jq";
import module namespace math = "http://www.w3.org/2005/xpath-functions/math";
import module namespace xs = "http://www.w3.org/2005/xpath-functions";
declare function ns:DGSProject($input)
  {

     let $flagcondition :=  for $cff in $input.courses[], $i in $input.profcoursepairs[]
                            where $i.sem = $cff.sem
                            let $innerconst := for
                            $ic in $cff.courses[]
                                               let $inside := fn:sum( for $li in $i.List[]
                                                                      where $ic = $li.course
                                                                      return $li.flag)
                                               return {course:$ic, flag:$inside}
                            return  {sem: $cff.sem, Value:$innerconst}


     let $profsatisfaction := for $profsat in $input.profcoursepairs[]
                              let $semsatis := for $ss in $profsat.List[]
                                               return{course:$ss.course, Prof: $ss.Prof, flag :$ss.flag}
                              return {sem:$profsat.sem,Courses_Offered:$semsatis}



     let $profcourses := for $p in $input.professors[].pname
                         let $c := for $sems in $profsatisfaction
                                   let $prof := for $course in $sems.Courses_Offered[]
                                                where $course.Prof=$p
                                                return {course:$course.course,flag :$course.flag}
                                   return {sem:$sems.sem,courses:$prof}
                         return {Prof:$p, sems:$c}


     let $preferences := for $p in $input.professors[].pname
                         let $prefs := for $sems in $input.prof_prefer[]
                                       return {sem:$sems.sem,preferences:[$sems.($p).pref1,$sems.($p).pref2]}
                         return {Prof:$p,sems:[$prefs]}


     let $profsatis := for $off in $profcourses
                       let $p := for $pref in $preferences
                                 where $pref.Prof=$off.Prof
                                 let $po := for $x in $off.sems[]
                                            let $pr := for $y in $pref.sems[]
                                                       where $y.sem=$x.sem
                                                       let $pen := for $c in $x.courses[]
                                                                   return if(($y.preferences[])[contains($$,$c.course)])
                                                                          then (0)
                                                                          else (-0.33 * $c.flag)
                                                       return (1+ fn:sum($pen))
                                            return {sem:$x.sem, satisfac:$pr}
                                 return $po
                       return {Prof:$off.Prof,satisfacPerSem:$p}





     let $profAvgSatis := for $p in $profsatis
                          let $s := fn:sum(for $sem in $p.satisfacPerSem[]
                                           return $sem.satisfac) div 4
                          return {Prof:$p.Prof, ProfAvgSatisfac: $s}




     let $avgSatis := fn:sum(for $p in $profAvgSatis return $p.ProfAvgSatisfac) div fn:sum(for $p in $profAvgSatis
     																					   return 1)


     (: Total Standard Deviation :)
     let $standardDeviation :=  fn:sum (for $pa in $profAvgSatis
                                        return ( fn:abs($pa.ProfAvgSatisfac - $avgSatis) ) )
                                        div fn:sum(for $p in $profAvgSatis return 1)



     (:Constraints...............................................:)


     let $flagSumCons := for $c in $flagcondition
                         let $innerconst := every $vc in $c.Value[] satisfies $vc.flag = 1
                         return $innerconst


     let $flagSumConstraint := every $i in $flagSumCons satisfies $i = true


     let $profflags := for $pf in $input.profcoursepairs[]
                       let $flags := for $p in $input.professors[].pname
                                     let $flagcount := fn:sum(for $fg in $pf.List[]
                                                              where $fg.Prof = $p
                                                              return $fg.flag)
                                     return {Prof:$p ,fcount:$flagcount}
                       return{sem:$pf.sem,Flags:$flags}


     let $minMaxConstr := for $pfg in $profflags
                          let $ppref := for $pr in $input.prof_prefer[]
                                        where $pfg.sem = $pr.sem
                                        let $prefcount := for $pcount in $pfg.Flags[]
                                                          let  $min := $pr.($pcount.Prof).min
                                                          let $max  :=  $pr.($pcount.Prof).max
                                                          let $check := $min le $pcount.fcount and $pcount.fcount le $max
                                                          return $check
                                        return $prefcount
                          let $innerconst := every $vc in $ppref satisfies $vc = true
                          return $innerconst


     let $minMaxConstraint := every $i in $minMaxConstr satisfies $i = true


     let $binaryFlagConstraint := every $x in $input.profcoursepairs[].List[].flag satisfies ($x ge 0 and $x le 1)


     let $constraints := (($flagSumConstraint and $minMaxConstraint) and $binaryFlagConstraint)
     						(: and (($standardDeviation le $input.maxSD and $standardDeviation ge $input.minSD))
:)
     (: Metrics................................................. :)


     (: Satisfaction of each professor per sem  :)
     let $satispersem := for $s in $input.courses[]
                         let $sems := for $sps in $profsatis
                                      let $inside := for $i in $sps.satisfacPerSem[]
                                                     where $i.sem = $s.sem
                                                     return $i.satisfac
                                      return $inside
                         return {sem:$s.sem, Satisfaction:$sems}


     (:mean satisfaction per semester  :)
     let $meansemsatis := for $m in $satispersem
                          return {sem : $m.sem, mean :fn:sum($m.Satisfaction[]) div 4}


     (:minimum and maximum satisfaction for each semester:)
     let $minmax := for $m in $satispersem
      				let $maxi := fn:max((for $mx in $m.Satisfaction[] return $mx))
                    let $mini := fn:min((for $mn in $m.Satisfaction[] return $mn))
                    let $diff := $maxi - $mini
                    return {sem:$m.sem, ratio: $diff}


     (:Standard deviation per sem :)
     let $sdpersem := for $sps in $satispersem
                      let $sd:= for $ms in $meansemsatis
                                where $sps. sem = $ms.sem
                                let $compute:= fn:sum (for $s in $sps.Satisfaction[]
                                                              return( fn:abs($s - $ms.mean ) ) ) div 4
                                return $compute

                      return {sem: $sps.sem, SD:$sd}


     let $coreCourses := for $sems in $input.courses[]
     					 let $courses := for $coursesoff in $sems.courses[]
     					 				 return if ($coursesoff eq $input.core_courses[] [$$ eq $coursesoff])
                                                then $coursesoff
                                                else ()
                         return {sem:$sems.sem,Count: count($courses),Courses: $courses}



     let $ftePerSem := for $sems in $input.courses[]
                       let $outside := fn:sum(for $profs in $profcourses
                                              let $inside := for $insems in $profcourses.sems[]
                                                             where $insems.sem = $sems.sem
                                                             let $allcourses := for $course in $insems.courses[]
                                                                                let $insidecourse := for $cd in $input.course_demand[],$dem in $cd.demand[]
                                                                                                      where ($cd.courses = $course.course and $dem.Prof = $profs.Prof)
                                                                                                      return fn:sum($cd.credit_hours * $dem.No_of_Students * $course.flag) div 12

                                                                                return $insidecourse
                                                             return $allcourses
                                              return $inside)
                       return {sem:$sems.sem, fte:$outside}


     let $utility := $avgSatis -  $standardDeviation


     return {AvgProfSatisfaction: $avgSatis, constraints: $constraints ,  CoreCourses: $coreCourses, FTEs: $ftePerSem, Unfairness: $standardDeviation, Utility: $utility }

  };


     (:
     (: Unfairness Ratio = StandardDeviation/(max - min)  :)
     let $unfairnessratio := for $sd in $sdpersem
                             let $ratio := for $mm in $minmax
                                           where $sd.sem = $mm.sem
                                           return ($sd.SD div $mm.ratio )

                             return {sem: $sd.sem,unfairnessratio: $ratio}

     let $overallunfairness:= fn:sum(for $fr in $unfairnessratio return $fr.unfairnessratio) div 4
     :)
