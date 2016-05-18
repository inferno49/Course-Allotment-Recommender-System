jsoniq version "1.0";

module namespace ns = "http://DGSProject/course_demand.jq";

declare variable $ns:course_demand := (
  { "courses": "CS550", "credit_hours":3, "demand":[ {"Prof":"Brodsky", "No_of_Students":34} ] },
  { "courses": "CS580", "credit_hours":3, "demand":[ {"Prof":"Tecuci", "No_of_Students":44},{"Prof":"Wechsler", "No_of_Students":24} ] },
  { "courses": "CS583", "credit_hours":3, "demand":[ {"Prof":"Dana", "No_of_Students":31},{"Prof":"Tecuci", "No_of_Students":14} ] },
  { "courses": "CS650", "credit_hours":3, "demand":[ {"Prof":"Brodsky", "No_of_Students":44} ] },
  { "courses": "CS681", "credit_hours":3, "demand":[ {"Prof":"Tecuci", "No_of_Students":39} ] },
  { "courses": "CS682", "credit_hours":3, "demand":[ {"Prof":"Wechsler", "No_of_Students":14} ] },
  { "courses": "CS685", "credit_hours":3, "demand":[ {"Prof":"Dana", "No_of_Students":32},{"Prof":"Tecuci", "No_of_Students":27} ] },
  { "courses": "CS773", "credit_hours":3, "demand":[ {"Prof":"Dana", "No_of_Students":38},{"Prof":"Wechsler", "No_of_Students":37} ] },
  { "courses": "CS787", "credit_hours":3, "demand":[ {"Prof":"Brodsky", "No_of_Students":27} ] },
  { "courses": "CS795", "credit_hours":3, "demand":[ {"Prof":"Dana", "No_of_Students":36} ] },
  { "courses": "SWE645", "credit_hours":3, "demand":[ {"Prof":"Wechsler", "No_of_Students":15} ] },
  { "courses": "INFS740", "credit_hours":3, "demand":[ {"Prof":"Brodsky", "No_of_Students":29} ] });
