-- Auto-generated from config_present.yml

let Item =
    { Type =
        { block : Optional (List ({ name : Text, copy : Optional ({ content : Text, dest : Text, backup : Bool }), register : Text, command : Optional Text, changed_when : Optional Text }))
    , rescue : Optional (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }) }))
    , always : Optional (List ({ name : Text, file : { name : Text, state : Text }, when : Text }))
    , name : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text })
  }
    , default =
        { block = None (List ({ name : Text, copy : Optional ({ content : Text, dest : Text, backup : Bool }), register : Text, command : Optional Text, changed_when : Optional Text }))
    , rescue = None (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }) }))
    , always = None (List ({ name : Text, file : { name : Text, state : Text }, when : Text }))
    , name = None Text
    , systemd = None ({ name : Text, enabled : Bool, state : Text })
  }
    }

in  [
    Item::{
      block = Some [
        {
          name = "Copy dnsmasq config",
          copy = Some {
            content = "{{ dnsmasq_config }}"
          , dest = "{{ dnsmasq_config_file }}"
          , backup = True
        },
          register = "config",
          command = None Text,
          changed_when = None Text
        }
      , {
          name = "Run validation",
          copy = None ({ content : Text, dest : Text, backup : Bool }),
          register = "check",
          command = Some "dnsmasq --test --conf-dir {{ dnsmasq_config_dir }}",
          changed_when = Some "config.changed"
        }
    ],
      rescue = Some [
        {
          name = "Slurp failed file and add line numbers",
          command = Some "cat -n {{ dnsmasq_config }}",
          register = Some "_slurp",
          debug = None ({ msg : Text }),
          copy = None ({ remote_src : Bool, dest : Text, src : Text })
        }
      , {
          name = "Dump failed configuration",
          command = None Text,
          register = None Text,
          debug = Some { msg = "{{ _slurp.stdout }}" },
          copy = None ({ remote_src : Bool, dest : Text, src : Text })
        }
      , {
          name = "Restore config file",
          command = None Text,
          register = None Text,
          debug = None ({ msg : Text }),
          copy = Some {
            remote_src = True
          , dest = "{{ dnsmasq_config }}"
          , src = "{{ config.backup_file }}"
        }
        }
    ],
      always = Some [
        {
          name = "Remove backup file"
        , file = { name = "{{ config.backup_file }}", state = "absent" }
        , when = "config['backup_file'] is defined"
      }
    ]
    }
  , Item::{
      name = Some "Restart dnsmasq",
      systemd = Some {
        name = "{{ dnsmasq_service_name }}"
      , enabled = True
      , state = "{{ 'restarted' if check.changed else 'started' }}"
    }
    }
]
