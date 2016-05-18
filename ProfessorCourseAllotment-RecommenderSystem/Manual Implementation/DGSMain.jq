jsoniq version "1.0";

import module namespace ns = "DGSProject"
  at "DGSProject.jq";
let $professors := (
    { pid: 14,
      pname: "Brodsky",
      can_teach: ["CS550", "CS787", "INFS740", "CS650" ]
    },
    { pid: 15,
      pname: "Tecuci",
      can_teach: ["CS681","CS583","CS580", "CS685"]
    },
    { pid: 16,
      pname: "Wechsler",
      can_teach: ["CS580", "CS682", "CS773", "SWE645"]
    },
    { pid: 17,
      pname: "Dana",
      can_teach: ["CS583", "CS685", "CS773","CS795"]
    })

    let $professors_preference := (
    {
      sem:1,
      Brodsky  : {pref1:"CS550" , pref2:"INFS740", min:1, max:2},
      Tecuci   : {pref1:"CS685" , pref2:"CS681"  , min:1, max:2},
      Wechsler : {pref1:"SWE645", pref2:"CS773"  , min:1, max:2},
      Dana     : {pref1:"CS773" , pref2:"CS583"  , min:1, max:2}
    },
    {
      sem:2,
      Brodsky  : {pref1:"CS550" , pref2:"CS650"  , min:1, max:2},
      Tecuci   : {pref1:"CS580" , pref2:"CS685"  , min:1, max:2},
      Wechsler : {pref1:"CS773" , pref2:"SWE645" , min:1, max:2},
      Dana     : {pref1:"CS685" , pref2:"CS583"  , min:1, max:2}
    },
    {
      sem:3,
      Brodsky  : {pref1:"CS787" , pref2:"CS650"  , min:1, max:2},
      Tecuci   : {pref1:"CS583" , pref2:"CS580"  , min:1, max:2},
      Wechsler : {pref1:"CS682" , pref2:"SWE645" , min:1, max:2},
      Dana     : {pref1:"CS583" , pref2:"CS685"  , min:1, max:2}
    },
    {
      sem:4,
      Brodsky  : {pref1:"CS550" , pref2:"INFS740", min:1, max:2},
      Tecuci   : {pref1:"CS580" , pref2:"CS685"  , min:1, max:2},
      Wechsler : {pref1:"CS682" , pref2:"CS580"  , min:1, max:2},
      Dana     : {pref1:"CS583" , pref2:"CS773"  , min:1, max:2}
    })

let $core_courses := ( ["CS583","CS550","CS580","ISA562","SWE619","CS581","CS584","CS555","CS540","SWE621","CS551"])

let $courses := (
    { sem: 1, courses: ["CS550", "INFS740" ,"CS681", "CS685", "CS773", "CS583","SWE645","CS795"]},
    { sem: 2, courses: ["CS583", "SWE645", "CS550", "CS650", "CS685", "CS580","CS681","CS773"]},
    { sem: 3, courses: ["CS650", "CS580", "CS787", "CS681", "CS682", "SWE645","CS583","CS685"]},
    { sem: 4, courses: ["INFS740", "CS550", "CS685", "CS580","CS773", "CS682","CS583","CS795"]})

let $course_demand := (
  { course: "CS550", credit_hours:3, demand:[ {Prof:"Brodsky", No_of_Students:34} ] },
  { course: "CS580", credit_hours:3, demand:[ {Prof:"Tecuci", No_of_Students:44},{Prof:"Wechsler", No_of_Students:24} ] },
  { course: "CS583", credit_hours:3, demand:[ {Prof:"Dana", No_of_Students:31},{Prof:"Tecuci", No_of_Students:14} ] },
  { course: "CS650", credit_hours:3, demand:[ {Prof:"Brodsky", No_of_Students:44} ] },
  { course: "CS681", credit_hours:3, demand:[ {Prof:"Tecuci", No_of_Students:39} ] },
  { course: "CS682", credit_hours:3, demand:[ {Prof:"Wechsler", No_of_Students:14} ] },
  { course: "CS685", credit_hours:3, demand:[ {Prof:"Dana", No_of_Students:32},{Prof:"Tecuci", No_of_Students:27} ] },
  { course: "CS773", credit_hours:3, demand:[ {Prof:"Dana", No_of_Students:38},{Prof:"Wechsler", No_of_Students:37} ] },
  { course: "CS787", credit_hours:3, demand:[ {Prof:"Brodsky", No_of_Students:27} ] },
  { course: "CS795", credit_hours:3, demand:[ {Prof:"Dana", No_of_Students:36} ] },
  { course: "SWE645", credit_hours:3, demand:[ {Prof:"Wechsler", No_of_Students:15} ] },
  { course: "INFS740", credit_hours:3, demand:[ {Prof:"Brodsky", No_of_Students:29} ] })

return ns:projectAnalytics({professors: $professors, courses: $courses, core_courses:$core_courses,proff_prefer: $professors_preference, course_demand: $course_demand})
