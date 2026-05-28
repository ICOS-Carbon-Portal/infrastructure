-- Auto-generated from config.yml

[
    {
      block = [
        {
          name = "Create zrepl.yaml",
          copy = Some { content = "{{ zrepl_config }}", dest = "/etc/zrepl/zrepl.yml", backup = True },
          register = Some "update",
          command = None Text,
          changed_when = None Text,
          notify = None Text
        }
      , {
          name = "Run validation",
          copy = None ({ content : Text, dest : Text, backup : Bool }),
          register = None Text,
          command = Some "zrepl configcheck",
          changed_when = Some "update.changed",
          notify = Some "restart zrepl"
        }
    ]
    , rescue = [
        {
          name = "Slurp failed file and add line numbers",
          command = Some "cat -n /etc/zrepl/zrepl.yml",
          register = Some "_slurp",
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          debug = None ({ msg : Text }),
          fail = None ({ msg : Text })
        }
      , {
          name = "Restore config file",
          command = None Text,
          register = None Text,
          copy = Some {
            remote_src = True
          , dest = "/etc/zrepl/zrepl.yml"
          , src = "{{ update.backup_file }}"
        },
          debug = None ({ msg : Text }),
          fail = None ({ msg : Text })
        }
      , {
          name = "Dump failed configuration",
          command = None Text,
          register = None Text,
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          debug = Some { msg = "{{ _slurp.stdout }}" },
          fail = None ({ msg : Text })
        }
      , {
          name = "Validation failed",
          command = None Text,
          register = None Text,
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          debug = None ({ msg : Text }),
          fail = Some { msg = "Error in config.yaml" }
        }
    ]
    , always = [
        {
          name = "Remove backup file"
        , file = { name = "{{ _r.backup_file }}", state = "absent" }
        , when = "_r['backup_file'] is defined"
      }
    ]
  }
]
