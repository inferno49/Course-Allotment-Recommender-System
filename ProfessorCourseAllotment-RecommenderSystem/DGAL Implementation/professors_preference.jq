jsoniq version "1.0";

module namespace ns = "http://DGSProject/professors_preference.jq";

declare variable $ns:professors_preference := (
{
  "sem":1,
  "Brodsky"  : {"pref1":"CS550" , "pref2":"INFS740", "min":1, "max":2},
  "Tecuci"   : {"pref1":"CS685" , "pref2":"CS681"  , "min":1, "max":3},
  "Wechsler" : {"pref1":"SWE645", "pref2":"CS773"  , "min":1, "max":2},
  "Dana"     : {"pref1":"CS773" , "pref2":"CS583"  , "min":1, "max":3}
},
{
  "sem":2,
  "Brodsky"  : {"pref1":"CS550" , "pref2":"CS650"  , "min":1, "max":2},
  "Tecuci"   : {"pref1":"CS685" , "pref2":"CS580"  , "min":1, "max":3},
  "Wechsler" : {"pref1":"CS773" , "pref2":"SWE645" , "min":1, "max":3},
  "Dana"     : {"pref1":"CS685" , "pref2":"CS583"  , "min":1, "max":2}
},
{
  "sem":3,
  "Brodsky"  : {"pref1":"CS787" , "pref2":"CS650"  , "min":1, "max":2},
  "Tecuci"   : {"pref1":"CS583" , "pref2":"CS580"  , "min":1, "max":3},
  "Wechsler" : {"pref1":"CS682" , "pref2":"SWE645" , "min":1, "max":2},
  "Dana"     : {"pref1":"CS583" , "pref2":"CS685"  , "min":1, "max":3}
},
{
  "sem":4,
  "Brodsky"  : {"pref1":"CS550" , "pref2":"INFS740", "min":1, "max":3},
  "Tecuci"   : {"pref1":"CS580" , "pref2":"CS685"  , "min":1, "max":2},
  "Wechsler" : {"pref1":"CS682" , "pref2":"CS580"  , "min":1, "max":2},
  "Dana"     : {"pref1":"CS583" , "pref2":"CS773"  , "min":1, "max":2}
});
