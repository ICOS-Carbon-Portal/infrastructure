-- Auto-generated from resolve-probe.yml

let Item =
    { Type =
        { when : Optional (List Text)
    , block : Optional (List ({ name : Text, systemd : Optional ({ name : Text }), register : Optional Text, when : Optional Text, set_fact : Optional ({ nebula_resolve_type : Text, cacheable : Bool }) }))
    , set_fact : Optional ({ name : Text, nebula_resolve_type : Text, cacheable : Bool })
    , name : Optional Text
    , debug : Optional ({ msg : Text })
  }
    , default =
        { when = None (List Text)
    , block = None (List ({ name : Text, systemd : Optional ({ name : Text }), register : Optional Text, when : Optional Text, set_fact : Optional ({ nebula_resolve_type : Text, cacheable : Bool }) }))
    , set_fact = None ({ name : Text, nebula_resolve_type : Text, cacheable : Bool })
    , name = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some [ "nebula_resolve_type == \"probe\"" ],
      block = Some [
        {
          name = "Query systemd for dhcpcd",
          systemd = Some { name = "dhcpcd" },
          register = Some "_r",
          when = None Text,
          set_fact = None ({ nebula_resolve_type : Text, cacheable : Bool })
        }
      , {
          name = "Set nebula_resolve_type to dnsmasq",
          systemd = None ({ name : Text }),
          register = None Text,
          when = Some "_r.status.ActiveState == \"active\"",
          set_fact = Some { nebula_resolve_type = "dnsmasq", cacheable = True }
        }
    ]
    }
  , Item::{
      when = Some [ "nebula_resolve_type == \"probe\"" ],
      block = Some [
        {
          name = "Query systemd for NetworkManager",
          systemd = Some { name = "NetworkManager" },
          register = Some "_r",
          when = None Text,
          set_fact = None ({ nebula_resolve_type : Text, cacheable : Bool })
        }
      , {
          name = "Set nebula_resolve_type to NetworkManager",
          systemd = None ({ name : Text }),
          register = None Text,
          when = Some "_r.status.ActiveState == \"active\"",
          set_fact = Some { nebula_resolve_type = "NetworkManager", cacheable = True }
        }
    ]
    }
  , Item::{
      when = Some [ "nebula_resolve_type == \"probe\"" ],
      block = Some [
        {
          name = "Query systemd for systemd-networkd",
          systemd = Some { name = "systemd-networkd" },
          register = Some "_r",
          when = None Text,
          set_fact = None ({ nebula_resolve_type : Text, cacheable : Bool })
        }
      , {
          name = "Set nebula_resolve_type to systemd-networkd",
          systemd = None ({ name : Text }),
          register = None Text,
          when = Some "_r.status.ActiveState == \"active\"",
          set_fact = Some { nebula_resolve_type = "systemd-networkd", cacheable = True }
        }
    ]
    }
  , Item::{
      when = Some [ "nebula_resolve_type == \"probe\"", "ansible_distribution == \"Debian\"" ],
      set_fact = Some {
        name = "Set nebula_resolve_type to dnsmasq"
      , nebula_resolve_type = "dnsmasq"
      , cacheable = True
    }
    }
  , Item::{
      when = Some [ "nebula_resolve_type == \"probe\"" ],
      set_fact = Some {
        name = "Set nebula_resolve_type to unknown"
      , nebula_resolve_type = "unknown"
      , cacheable = True
    }
    }
  , Item::{
      name = Some "Inform about the client dns resolution setup",
      debug = Some {
        msg = "nebula_resolve_type == {{ nebula_resolve_type }} for {{ ansible_lsb.id }}/{{ ansible_lsb.major_release }}"
    }
    }
]
