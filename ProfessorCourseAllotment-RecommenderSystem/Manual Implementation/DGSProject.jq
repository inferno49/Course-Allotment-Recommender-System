jsoniq version "1.0";

module namespace ns = "DGSProject";

declare function ns:projectAnalytics($input)
{
(:---- list of all the courses (per sem) along with the professors who can teach the course  (per course structure)------:)
    let $CourseTeachable := (for $co in $input.courses[]
      let $course:= for $c in $co.courses[]
                    let $assign:= for $p in $input.professors[]
                                  let $w := for $pi in $p.can_teach[] where $c = $pi return $p.pname
                                  return $w
                    return {course: $c, Prof : $assign , No_of_Prof: count($assign)}
      return {sem:$co.sem,Courses_Offered:$course})

(:--------- list of courses (per sem) that a professor can teach (per professor structure) ----------:)

 let $prof_can_teach_sem:=for $sems in $input.courses[]
                          let $prof_teach:= for $p in $input.professors[]
                                            let $courseoff := for $c in $sems
                                                let $courses := for $course in $c.courses[]
                                                      let $match :=  for $pi in $p.can_teach[] where $course = $pi
                                                      return $course
                                                return $match
                                            return $courses
                                  return {Proff_id:$p.pid,Proff_Name:$p.pname,Can_Teach_Courses:$courseoff}

                            return {sem:$sems.sem,List:$prof_teach}

(: Courses that can be taught by only 1 Professor , assignmnet done!!:)
let $onecourse:=  for $y in $CourseTeachable
                  let $courses:=for $x in $y.Courses_Offered[] where $x.No_of_Prof=1

                  return {course: $x.course, Prof : $x.Prof}
    return {sem:$y.sem,Courses_Offered:$courses}

  let $remcourseAfterone := ns:remainingcourses ({remcourse:$CourseTeachable,allotment:$onecourse})
  let $remProffessorsAfterone := ns:remainingProfessors ({concatenated:$onecourse,inputProf:$input.professors[],inputPref: $input.proff_prefer[]})


(:no. of courses assigned so far to Professor :)

(:let $remainp :=  for $rp in $remProffessorsAfterone
let $remp := for $main in $rp.RemCount[]
               return  $main.Prof
            return {sem:$rp.sem, remp: [$remp]}


-- no. of courses a professor can teach from the remaining courses ---------------

let $noProfCanTeachFromRem:= for $sems in $remcourseAfterone
                             let $profs := for $rem in $remainp where $rem.sem = $sems.sem return $rem.remp[]
                             let $profcount:=for $p in $profs
                                             let $count:=for $x in $sems.Courses_Offered[].Prof[]
                                                         where $x=$p
                                                         return count($x)
                                              order by sum($count)
                                              return {$p : sum($count)}
                             return {sem:$sems.sem,can_teach:$profcount}

----------- if a prof can teach only 1 course from remaining courses, assign it to him -------------

let $intermediateAllotment:=for $sem in $remcourseAfterone
                            let $courses:=for $x in $sem.Courses_Offered[]
                                          let $y:= for $profcount in $noProfCanTeachFromRem
                                                   where $profcount.sem = $sem.sem
                                                   let $profallot:= for $z in $x.Prof[]
                                                                    where $profcount.can_teach[].($z) =1
                                                                    return {course:$x.course,Prof:$z}
                                                    return $profallot
                                           return $y
                            return {sem:$sem.sem,Courses_Offered:[$courses]} :)



let $intermediateAllotmentfrst := ns:intermediateAllotment({remainProf :$remProffessorsAfterone, remaincourses : $remcourseAfterone})
let $concatenate :=   ns:concatenateResults ({one:$onecourse,two:$intermediateAllotmentfrst})

let $remProffessorsafterInter := ns:remainingProfessors ({concatenated:$concatenate,inputProf:$input.professors[],inputPref: $input.proff_prefer[]})
let $remcourseafterintermediate := ns:remainingcourses ({remcourse:$remcourseAfterone,allotment:$intermediateAllotmentfrst})

let $frstprefalott := ns:assignbypref({inputPref: $input.proff_prefer[],remainingcourses:$remcourseafterintermediate,remainingProfessors:$remProffessorsafterInter,pref : ["pref1"]})






let $distinct_course := distinct-values(for $temp in $frstprefalott.Courses_Offered[]
                                                      return $temp.course)

  let $countCalculation:= for $tsa in $frstprefalott
                          let $discount := for $dc in $distinct_course
                                          let $compare:= for $cmp in $tsa.Courses_Offered[]
                                                          where $dc = $cmp.course
                                                          return count($cmp.course)

                                          return {course:$dc, Count: count($compare)}

                          return {sem:$tsa.sem,Courses_Offered:$discount}


  let $actualPref1 := for $tsa in $frstprefalott
                      let $countCal := for $cC in $countCalculation
                                       where $tsa.sem = $cC.sem
                                       let $inside := for $t in $tsa.Courses_Offered[], $c in $cC.Courses_Offered[]
                                                      where $t.course = $c.course and $c.Count =1
                                                      return  {course:$t.course, Prof:$t.Prof}


                                        return $inside
                      return {sem:$tsa.sem,Courses_Offered:[$countCal]}

       let $concatenateactualPref1 :=   ns:concatenateResults ({one:$concatenate,two:$actualPref1})
    let $remProffessorsAfteractualPref1 := ns:remainingProfessors ({concatenated:$concatenateactualPref1,inputProf:$input.professors[],inputPref: $input.proff_prefer[]})
         let $remcourseactualPref1 := ns:remainingcourses ({remcourse:$remcourseafterintermediate,allotment:$actualPref1})


let $intermediateAllotmentsecond := ns:intermediateAllotment({remainProf :$remProffessorsAfteractualPref1, remaincourses : $remcourseactualPref1})


                    let $prefRefined := for $tsa in $frstprefalott
                                                  let $countCal := for $cC in $countCalculation
                                                   where $tsa.sem = $cC.sem
                                                    let $inside := for $t in $tsa.Courses_Offered[], $c in $cC.Courses_Offered[]
                                                                    where $t.course = $c.course and $c.Count >1
                                                                    return  {course:$t.course, Prof:$t.Prof}


                                                    return $inside
                                                return {sem:$tsa.sem,Courses_Offered:[$countCal]}


                                                let $improveAllotment := for $tsa in $prefRefined
                                                                        return if (exists ($tsa.Courses_Offered[]))
                                                                        then $tsa  else ()

let $improveprefAllotment := for $ia2 at $i in $improveAllotment
                          let $courseoff:= for $co in $ia2.Courses_Offered[][$i]
                                           return $ia2.Courses_Offered[][$i]
                           return   {sem:$ia2.sem,Courses_Offered:[$courseoff]}




let $finalfrstpref :=   ns:concatenateRakesh ({one:$actualPref1,two:$improveprefAllotment})



let $concatenatefrst :=   ns:concatenateResults ({one:$concatenate,two:$finalfrstpref})

let $remProffessorsAfterfirstPref := ns:remainingProfessors ({concatenated:$concatenatefrst,inputProf:$input.professors[],inputPref: $input.proff_prefer[]})
let $remcourseafterfirst := ns:remainingcourses ({remcourse:$remcourseafterintermediate,allotment:$finalfrstpref})


let $secondprefalott := ns:assignbypref({inputPref: $input.proff_prefer[],remainingcourses:$remcourseafterfirst,remainingProfessors:$remProffessorsAfterfirstPref,pref : ["pref2"]})

let $concatenatesecond :=   ns:concatenateResults ({one:$concatenatefrst,two:$secondprefalott})

let $remProffessors := ns:remainingProfessors ({concatenated:$concatenatesecond,inputProf:$input.professors[],inputPref: $input.proff_prefer[]})
let $remcourseaftersecond := ns:remainingcourses ({remcourse:$remcourseafterfirst,allotment:$secondprefalott})

let $finalAllotment:=  for $x in $remcourseaftersecond
                       let $final:= for $y in $x.Courses_Offered[]
                                    let $courses:= for $z in $y.Prof[]
                                                   let $p:= for $a in $remProffessors
                                                            where $x.sem = $a.sem and $a.RemCount[].Prof = $z
                                                            return {course:$y.course,Prof:$z}
                                                    return $p
                                    return $courses
                        return {sem:$x.sem, Courses_Offered:[$final]}

    let $concatenatefinal :=   ns:concatenateResults ({one:$concatenatesecond,two:$finalAllotment})

    let $remProffessors := ns:remainingProfessors ({concatenated:$concatenatefinal,inputProf:$input.professors[],inputPref: $input.proff_prefer[]})
    let $remcourseafterfinal := ns:remainingcourses ({remcourse:$remcourseaftersecond,allotment:$finalAllotment})




    (: Constraints .............................. :)

    (: Inner constraint1 calculation :)
    let $innerconstraint := for $cff in  $concatenatefinal.Courses_Offered[]
                            let $innerconst := for $i in $input.professors[]
                                               where $i.pname = $cff.Prof
                                               return if (($i.can_teach[])[contains($$,$cff.course)])
                                               then true
                                               else false
                            return  $innerconst

    let $constraint1 := every $i in $innerconstraint satisfies $i = true

    (: Inner constraint2 calculation :)
    let $constr2:=for $p in $input.professors[].pname
                      let $pr:=for $prof in $input.proff_prefer[]
                               let $check:=for $sems in $concatenatefinal
                                           where $prof.sem = $sems.sem
                                           return ($prof.($p).min <= sum(for $x in $sems.Courses_Offered[] where $x.Prof=$p return 1) and sum(for $x in $sems.Courses_Offered[] where $x.Prof=$p return 1) <= $prof.($p).max)
                               return $check
                      return $pr

    let $constraint2:=every $x in $constr2 satisfies true

    let $allconstraints := $constraint1 and $constraint2


    (: Core courses ....................  :)
    let $coreCourses := for $cf in $concatenatefinal
        let $no_core := for $nc in $input.core_courses
            let $num_inside := for $ni in $cf.Courses_Offered[]
                              return if ($ni.course eq $nc[] [$$ eq $ni.course])
                                    then $ni.course
                                    else ()

                          return {Count: count($num_inside), Courses:$num_inside}
                  return {sem:$cf.sem,Core_Courses: $no_core}

    (:------------ Structures used for calculating professor satisfaction ratio --------------:)

    let $profcourses:=for $p in $input.professors[].pname
                      let $c:=for $sems in $concatenatefinal
                              let $prof:=for $course in $sems.Courses_Offered[]
                                         where $course.Prof=$p
                                         return $course.course
                              return {sem:$sems.sem,courses:$prof}
                      return {Prof:$p, sems:$c}

    let $preferences:=for $p in $input.professors[].pname
                      let $prefs:=for $sems in $input.proff_prefer[]
                                  return {sem:$sems.sem,preferences:[$sems.($p).pref1,$sems.($p).pref2]}
                      return {Prof:$p,sems:[$prefs]}

(:---------- average satisfaction ratio of each professors per semester -----------------:)

let $profsatis:=for $off in $profcourses
                let $p:=for $pref in $preferences
                        where $pref.Prof=$off.Prof
                        let $po:=for $x in $off.sems[]
                                 let $pr:=for $y in $pref.sems[]
                                          where $y.sem=$x.sem
                                          let $pen:=for $c in $x.courses[]
                                                    return if(($y.preferences[])[contains($$,$c)])
                                                           then (0)
                                                           else (-0.4)
                                          return (if((1+sum($pen)) > 0) then (1+sum($pen)) else 0)
                                 return {sem:$x.sem, satisfac:$pr}
                       return $po
                return {Prof:$off.Prof,satisfacPerSem:$p}

(:---------- average satisfaction ratio of each professor (among all semesters) -----------------:)

let $profAvgSatis:=for $p in $profsatis
                   let $s:=sum(for $sem in $p.satisfacPerSem[] return $sem.satisfac) div 4
                   return {Prof:$p.Prof, ProfAvgSatisfac: $s}

(:----------average satisfaction ratio among all professors-----------------:)

let $avgSatis:={AvgSatisRatio: sum(for $p in $profAvgSatis return $p.ProfAvgSatisfac) div sum(for $p in $profAvgSatis return 1)}

(:-- jsoniq does not hav square root function so cant calculate standard devation, hence varience for fairness measure --:)

let $fairnessVarience:=sum(for $pa in $profAvgSatis
                                  return ($pa.ProfAvgSatisfac - $avgSatis.AvgSatisRatio)*($pa.ProfAvgSatisfac - $avgSatis.AvgSatisRatio))
                                  div sum(for $p in $profAvgSatis return 1)

(:-- FTE or Full_Time_Equivalent is calculated by credit_hours_of_course * number_of_students_taking_course / 12 --:)
(:----------------fte per sem--------------:)

let $ftePerSem:=for $x in $concatenatefinal
                let $persem:=sum(for $y in $x.Courses_Offered[]
                                 let $courses:=for $cd in $input.course_demand[],$dem in $cd.demand[]
                                               where $cd.course = $y.course and $dem.Prof = $y.Prof
                                               return $cd.credit_hours * $dem.No_of_Students div 12
                                 return $courses)
                return {sem:$x.sem, fte:$persem}

(:----------------total fte over 4 sems--------------:)
let $fteTotal:=sum(for $s in $ftePerSem return $s.fte) div 4


return {FinalAllotment:$concatenatefinal,ConstraintsSatisfied:$allconstraints,CoreCourses:$coreCourses,AverageProfessorSatisfactionRatio:$avgSatis,fairnessVarience:$fairnessVarience,TotalFTEs:$fteTotal}



};


(:--------------------------- other functions called in code---------------------------:)
declare function ns:remainingcourses($remcourse_and_allotment)
{
let $remafter :=  for $rem in $remcourse_and_allotment.remcourse[], $a in $remcourse_and_allotment.allotment[]
                  where $rem.sem  eq $a.sem
  let $remain := for $main in $rem.Courses_Offered[]
                      return  $main.course
      let $alloted:= distinct-values(for $al in $a.Courses_Offered[]
                        return $al.course)

let $final := for $r in $remain
              return if(($alloted)[contains($$,$r)])
                then ()
               else $r

let $finalstruct := for $fin in $final
let   $structure    := for $struct in $rem.Courses_Offered[]
                          where $struct.course = $fin
                         return {course: $struct.course, Prof : $struct.Prof}
                         return $structure


                return {sem:$rem.sem,Courses_Offered:[$finalstruct]}


                return $remafter

        };

  declare function ns:remainingProfessors($input_allotment)
  {
    let $noAllotment := for $o in $input_allotment.concatenated[]
                                            let $x:= for $p in $input_allotment.inputProf[].pname
                                                     let $number:= for $n in $o.Courses_Offered[]
                                                    where $n.Prof =$p
                                                    return $n.Prof
                                                    return {Proff:$p,Count: count($number)}

                    return {sem:$o.sem,Course_Count:$x}


(:Professors remaining per sem after one and intermediateAllotment:)
let $remProffessors := for $na in $noAllotment
let $rem := for $r in $na.Course_Count[]
  let $remi := for $ri in $input_allotment.inputPref[]
               where  $na.sem = $ri.sem
               return $ri.($r.Proff).max
               let $temp := $remi -$r.Count
                return if ($temp>0) then
                     {Prof:$r.Proff, rem:($remi -$r.Count)}
                     else ()
return {sem:$na.sem,RemCount:[$rem]}

return $remProffessors


  };


  declare function ns:intermediateAllotment($remains)
  {
    let $remainp :=  for $rp in $remains.remainProf[]
    let $remp := for $main in $rp.RemCount[]
                   return  $main.Prof
                return {sem:$rp.sem, remp: [$remp]}


    (:)-- no. of courses a professor can teach from the remaining courses ---------------:)

    let $noProfCanTeachFromRem:= for $sems in  $remains.remaincourses[]
                                 let $profs := for $rem in $remainp where $rem.sem = $sems.sem return $rem.remp[]
                                 let $profcount:=for $p in $profs
                                                 let $count:=for $x in $sems.Courses_Offered[].Prof[]
                                                             where $x=$p
                                                             return count($x)
                                                  order by sum($count)
                                                  return {$p : sum($count)}
                                 return {sem:$sems.sem,can_teach:$profcount}

    (:)----------- if a prof can teach only 1 course from remaining courses, assign it to him -------------:)

    let $intermediateAllotment:=for $sem in $remains.remaincourses[]
                                let $courses:=for $x in $sem.Courses_Offered[]
                                              let $y:= for $profcount in $noProfCanTeachFromRem
                                                       where $profcount.sem = $sem.sem
                                                       let $profallot:= for $z in $x.Prof[]
                                                                        where $profcount.can_teach[].($z) =1
                                                                        return {course:$x.course,Prof:$z}
                                                        return $profallot
                                               return $y
                                return {sem:$sem.sem,Courses_Offered:[$courses]}

          return $intermediateAllotment


  };

  declare function ns:concatenateRakesh($struct_to_concat)
  {
    let $concatenated := for $one in $struct_to_concat.one[]

        let $concat:=   for  $two in $struct_to_concat.two
                         return if ($one.sem = $two.sem) then
                               ({$one.Courses_Offered[],$two.Courses_Offered})
                               else
                               {$one.Courses_Offered}
             return     { sem:$one.sem, Courses_Offered:$concat }
             return $concatenated
  };

  declare function ns:concatenateResults($struct_to_concat)
  {
    let $concatenated := for $one in $struct_to_concat.one[], $inter in $struct_to_concat.two[]
                         where $one.sem = $inter.sem
                       return {sem:$one.sem, Courses_Offered:($one.Courses_Offered[], $inter.Courses_Offered[])}
             return $concatenated
  };
  declare function ns:assignbypref($inputassign)
  {
    let $remain :=  for $r in $inputassign.remainingcourses[]
                    let $rema := for $main in $r.Courses_Offered[]
                                 return  $main.course
                    return {sem:$r.sem, remc: [$rema]}

    let $prefalott :=  for $inp in $inputassign.inputPref[], $rempro in $inputassign.remainingProfessors[]
                       where $inp.sem = $rempro.sem
                       let $rem_course := for $r in $remain
                                          where $r.sem = $inp.sem
                                          return $r.remc

     let $temp := $inputassign.pref[]

     let $prof_assign:= for $rc in $rempro.RemCount[]
                        let $prof_pref := $inp.($rc.Prof).$temp

    let $remcheck := $rem_course[]

    let  $temp :=  if(($remcheck)[contains($$,$prof_pref)])
                        then
                        {course:$prof_pref, Prof : $rc.Prof}
                  else ()
                  return $temp

                   return {sem:$inp.sem, Courses_Offered :[ $prof_assign]}

                   return $prefalott

  };



  (:  Extra code---removed code---might use later---  .......................................................................................


///////// for removing duplicates
  let $countCalculation:= for $tsa in $tempSecondAllotment
              let $discount := for $dc in $distinct_course
                let $compare:= for $cmp in $tsa.Courses_Offered[]
                            where $dc = $cmp.course
                            return count($cmp.course)

            return {course:$dc, Count: count($compare)}

      return {sem:$tsa.sem,Courses_Offered:$discount}



    let $secondAllotment := for $tsa in $tempSecondAllotment
        let $countCal := for $cC in $countCalculation   where $tsa.sem = $cC.sem
                  let $inside := for $t in $tsa.Courses_Offered[], $c in $cC.Courses_Offered[]
                                where $t.course = $c.course
                                and $c.Count >1
                                      return
                                         {$t.course:$t.Prof}


                    return $inside
                    return
                    {sem:$tsa.sem,Courses_Offered:[$countCal]}

let $improveAllotment := for $tsa in $secondAllotment
return if (exists ($tsa.Courses_Offered[]))
  then $tsa  else ()


let $improveAllotment2 := for $ia2 in $improveAllotment
let $courseoff:= for $co in $ia2.Courses_Offered[][1]
                   return $ia2.Courses_Offered[][1]
return   {sem:$ia2.sem,Courses_Offered:$courseoff}


///end of function to remove duplicates.................................................................

//Extra code--might require later ......................................

declare function ns:secondAllotment($remcourse_and_allotment)
  {
    let $outsiderem:= for $r in $remcourse_and_allotment.allotment[]
let $insiderem := for $rem in $r.Courses_Offered[]
let $proffpossible := for $ri in $rem.Prof[]
let $prefer:= for $pr in $remcourse_and_allotment.var[] where $pr.sem = $r.sem and $pr.($ri).pref1 = $rem.course
                  return {course:$rem.course,Prof:$ri}


return $prefer
return $proffpossible

return {sem:$r.sem,Courses_Offered:$insiderem}





let $compAllotment:= ns:secondAllotment({remcourse:$remcourse,allotment:$assignFinal})
                    else if ($pr.($ri).pref2 = $r.course) then
                       {Prof:$ri,Course:$r.course}


return $outsiderem
  };



  count after 1st preference


  let $secondAllotment := for $tsa in $tempSecondAllotment
      let $countCal := for $cC in $countCalculation   where $tsa.sem = $cC.sem
                    let $inside := for $t in $tsa.Courses_Offered[], $c in $cC.Courses_Offered[]
                                            where $t.course = $c.course
                                            and $c.Count =1 and $c.Count != null
                                            return {$t.course, $t.Prof}
  return $inside

  return {sem:$tsa.sem,Courses_Offered:$countCal}


                      let $ins2 := for $i2 in $temp.Courses_Offered[]
                                    let $courses:= count(for $find in $i2
                                                    where $find.course = $c
                                                    return $find.course)
                                      return if ($courses < 2)
                                then {course:$i2.course, Prof: $i2.Prof}
                                else ()
                                  return $ins2

  return {sem:$temp.sem,Courses_Offered:$ins}



   return $CourseTeachable

  let $remafter := ns:remainingcourses ({remcourse:$CourseTeachable,allotment:$secondAllotment})
  let $var := $input.proff_prefer[]
  let $secondAllotment :=ns:secondAllotment({input:$var,allotment:$remcourseafterintermediate})
     return $secondAllotment


  let $secondAllotment :=ns:secondAllotment({input:$var,allotment:$remcourseafterintermediate})
     return $secondAllotment




   let $remcourse:=  for $y in $CourseTeachable
     let $courses:=for $x in $y.Courses_Offered[] where $x.No_of_Prof>1
                   return {course: $x.course, Prof : $x.Prof}
     return {sem:$y.sem,Courses_Offered:$courses}


     declare function ns:secondAllotment($remcourse_and_allotment)
       {
         let $outsiderem:= for $r in $remcourse_and_allotment.allotment[]
     let $insiderem := for $rem in $r.Courses_Offered[]
     let $proffpossible := for $ri in $rem.Prof[]
     let $prefer:= for $pr in $remcourse_and_allotment.var[] where $pr.sem = $r.sem and $pr.($ri).pref1 = $rem.course
                       return {course:$rem.course,Prof:$ri}


     return $prefer
     return $proffpossible

     return {sem:$r.sem,Courses_Offered:$insiderem}



     let $compAllotment:= ns:secondAllotment({remcourse:$remcourse,allotment:$assignFinal})
                         else if ($pr.($ri).pref2 = $r.course) then
                            {Prof:$ri,Course:$r.course}


     return $outsiderem
       };

:)
