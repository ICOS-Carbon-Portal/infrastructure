-- Auto-generated from config.yml

[
    {
      block = [
        {
          name = "Copy nebula_config.yml",
          template = Some {
            src = "{{ nebula_config_file }}"
          , dest = "{{ nebula_etc_dir }}/config.yml"
          , lstrip_blocks = True
          , backup = True
        },
          register = Some "update",
          notify = Some "restart nebula",
          command = None Text,
          changed_when = None Bool
        }
      , {
          name = "Run validation",
          template = None ({ src : Text, dest : Text, lstrip_blocks : Bool, backup : Bool }),
          register = None Text,
          notify = None Text,
          command = Some "nebula -test -config {{ update.dest }}",
          changed_when = Some False
        }
    ]
    , rescue = [
        {
          name = "Slurp failed file and add line numbers",
          command = Some "cat -n \"{{ nebula_etc_dir }}/config.yml\"",
          register = Some "_slurp",
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          when = None Text,
          debug = None ({ msg : Text }),
          fail = None ({ msg : Text })
        }
      , {
          name = "Restore config file",
          command = None Text,
          register = None Text,
          copy = Some {
            remote_src = True
          , dest = "{{ nebula_etc_dir }}/config.yml"
          , src = "{{ update.backup_file }}"
        },
          when = Some "update['backup_file'] is defined",
          debug = None ({ msg : Text }),
          fail = None ({ msg : Text })
        }
      , {
          name = "Dump failed configuration",
          command = None Text,
          register = None Text,
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          when = None Text,
          debug = Some { msg = "{{ _slurp.stdout }}" },
          fail = None ({ msg : Text })
        }
      , {
          name = "Fail",
          command = None Text,
          register = None Text,
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          when = None Text,
          debug = None ({ msg : Text }),
          fail = Some { msg = "Nebula config file is broken" }
        }
    ]
    , always = [
        {
          name = "Remove backup file"
        , file = { name = "{{ update.backup_file }}", state = "absent" }
        , when = "update['backup_file'] is defined"
      }
    ]
  }
]
