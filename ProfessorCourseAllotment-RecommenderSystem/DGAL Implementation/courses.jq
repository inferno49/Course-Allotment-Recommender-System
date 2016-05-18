jsoniq version "1.0";

module namespace ns = "http://DGSProject/courses.jq";

declare variable $ns:courses := (
    { sem: 1, courses: ["CS550", "INFS740" ,"CS681", "CS685", "CS773", "CS583","SWE645","CS795"]},
    { sem: 2, courses: ["CS583", "SWE645", "CS550", "CS650", "CS685", "CS580","CS681","CS773"]},
    { sem: 3, courses: ["CS650", "CS580", "CS787", "CS681", "CS682", "SWE645","CS583","CS685"]},
    { sem: 4, courses: ["INFS740", "CS550", "CS685", "CS580","CS773", "CS682","CS583","CS795"]});
