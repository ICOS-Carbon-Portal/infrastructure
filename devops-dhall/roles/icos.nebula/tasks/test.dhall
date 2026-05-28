-- Auto-generated from test.yml

let Item =
    { Type =
        { name : Optional Text
    , meta : Optional Text
    , when : Optional (List Text)
    , block : Optional (List ({ name : Text, apt : Optional ({ update_cache : Bool, cache_valid_time : Natural, name : Text }), shell : Optional Text, changed_when : Optional Bool }))
    , command : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { name = None Text
    , meta = None Text
    , when = None (List Text)
    , block = None (List ({ name : Text, apt : Optional ({ update_cache : Bool, cache_valid_time : Natural, name : Text }), shell : Optional Text, changed_when : Optional Bool }))
    , command = None Text
    , changed_when = None Bool
  }
    }

in  [
    Item::{ name = Some "Flush handlers", meta = Some "flush_handlers" }
  , Item::{
      when = Some [ "nebula_resolve_servers", "nebula_resolve_test" ],
      block = Some [
        {
          name = "Install dnsutils",
          apt = Some { update_cache = True, cache_valid_time = 86400, name = "dnsutils" },
          shell = None Text,
          changed_when = None Bool
        }
      , {
          name = "Check that nebula dns resolution works",
          apt = None ({ update_cache : Bool, cache_valid_time : Natural, name : Text }),
          shell = Some "dig {{ nebula_resolve_test }}",
          changed_when = Some False
        }
    ]
    }
  , Item::{
      name = Some "Check that nebula is working",
      command = Some "ping -w 10 -c 1 {{ nebula_ping_host }}",
      changed_when = Some False
    }
  , Item::{
      name = Some "Check that ordinary dns resolution is still working",
      command = Some "ping -w 10 -c 1 google.com",
      changed_when = Some False
    }
]
