jsoniq version "1.0";

module namespace ns = "http://DGSProject/professors.jq";

declare variable $ns:professors := (
    { "pid": 14,
      "pname": "Brodsky",
      "can_teach": ["CS550", "CS787", "INFS740", "CS650" ]
    },
    { "pid": 15,
      "pname": "Tecuci",
      "can_teach": ["CS681","CS583","CS580", "CS685"]
    },
    { "pid": 16,
      "pname": "Wechsler",
      "can_teach": ["CS580", "CS682", "CS773", "SWE645"]
    },
    { "pid": 17,
      "pname": "Dana",
      "can_teach": ["CS583", "CS685", "CS773","CS795"]
    });
