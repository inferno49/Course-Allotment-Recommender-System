jsoniq version "1.0";


import module namespace dgal ="http://mason.gmu.edu/~mnachawa/dgal.jq";

import module namespace ns  = "http://DGSProject/DGSProject.jq";
import module namespace ns1 = "http://DGSProject/professors.jq";
import module namespace ns2 = "http://DGSProject/courses.jq";
import module namespace ns3 = "http://DGSProject/professors_preference.jq";
import module namespace ns4 = "http://DGSProject/core_courses.jq";
import module namespace ns5 = "http://DGSProject/ProfCoursePairs.jq";
import module namespace ns6 = "http://DGSProject/course_demand.jq";


let $input :=( { professors:$ns1:professors, courses:$ns2:courses, prof_prefer:$ns3:professors_preference,
                 core_courses:$ns4:core_courses, profcoursepairs:$ns5:ProfCoursePairs, course_demand:$ns6:course_demand } )





return dgal:argmax($input, ns:DGSProject#1,"AvgProfSatisfaction",{language: "opl", solver : "cplex"})


(:





return (

for $i in (0.060, 0.075, 0.090, 0.105, 0.120, 0.135, 0.150, 0.165, 0.180, 0.195)

return ns:DGSProject(dgal:argmax({|$input,{minSD: $i, maxSD: $i + 0.015}|}, ns:DGSProject#1,"AvgProfSatisfaction",{language: "opl", solver : "cplex"}))

 )
return ns:DGSProject($input)


return ns:DGSProject(dgal:argmax({|$input,{maxSD: $i * .1}|}, ns:DGSProject#1,"totalsatisfaction",{language: "opl", solver : "cplex"})) )

}

:)
