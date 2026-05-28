-- Auto-generated from config_present.yml

let Item =
    { Type =
        { block : Optional (List ({ name : Text, copy : Optional ({ dest : Text, content : Text, backup : Bool }), register : Text, shell : Optional Text, changed_when : Optional Text, failed_when : Optional (List Text), notify : Optional Text }))
    , rescue : Optional (List ({ name : Text, command : Optional Text, changed_when : Optional Bool, register : Optional Text, copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), debug : Optional ({ msg : Text }), fail : Optional ({ msg : Text }) }))
    , always : Optional (List ({ name : Text, file : { name : Text, state : Text }, when : Text }))
    , name : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text })
  }
    , default =
        { block = None (List ({ name : Text, copy : Optional ({ dest : Text, content : Text, backup : Bool }), register : Text, shell : Optional Text, changed_when : Optional Text, failed_when : Optional (List Text), notify : Optional Text }))
    , rescue = None (List ({ name : Text, command : Optional Text, changed_when : Optional Bool, register : Optional Text, copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), debug : Optional ({ msg : Text }), fail : Optional ({ msg : Text }) }))
    , always = None (List ({ name : Text, file : { name : Text, state : Text }, when : Text }))
    , name = None Text
    , systemd = None ({ name : Text, enabled : Bool, state : Text })
  }
    }

in  [
    Item::{
      block = Some [
        {
          name = "Create telegraf config file",
          copy = Some {
            dest = "{{ telegraf_config_root }}/{{ telegraf_config_file }}"
          , content = "{{ telegraf_config }}"
          , backup = True
        },
          register = "update",
          shell = None Text,
          changed_when = None Text,
          failed_when = None (List Text),
          notify = None Text
        }
      , {
          name = "Run validation",
          copy = None ({ dest : Text, content : Text, backup : Bool }),
          register = "test",
          shell = Some "telegraf --test --config {{ update.dest }} > /dev/null",
          changed_when = Some "update.changed",
          failed_when = Some [ "test.failed", "test.stderr.find('no inputs found') < 0" ],
          notify = Some "reload telegraf"
        }
    ],
      rescue = Some [
        {
          name = "Slurp failed file and add line numbers",
          command = Some "cat -n {{ update.dest }}",
          changed_when = Some False,
          register = Some "_slurp",
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          debug = None ({ msg : Text }),
          fail = None ({ msg : Text })
        }
      , {
          name = "Restore config file",
          command = None Text,
          changed_when = None Bool,
          register = None Text,
          copy = Some { remote_src = True, dest = "{{ update.dest }}", src = "{{ update.backup_file }}" },
          debug = None ({ msg : Text }),
          fail = None ({ msg : Text })
        }
      , {
          name = "Dump failed configuration",
          command = None Text,
          changed_when = None Bool,
          register = None Text,
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          debug = Some { msg = "{{ _slurp.stdout }}" },
          fail = None ({ msg : Text })
        }
      , {
          name = "Fail",
          command = None Text,
          changed_when = None Bool,
          register = None Text,
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          debug = None ({ msg : Text }),
          fail = Some { msg = "Telegraf config file is broken" }
        }
    ],
      always = Some [
        {
          name = "Remove backup file"
        , file = { name = "{{ update.backup_file }}", state = "absent" }
        , when = "update['backup_file'] is defined"
      }
    ]
    }
  , Item::{
      name = Some "Make sure telegraf is started",
      systemd = Some { name = "telegraf", enabled = True, state = "started" }
    }
]
