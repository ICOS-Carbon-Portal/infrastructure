-- Auto-generated from nginx.yml

let Item =
    { Type =
        { import_role : Optional ({ name : Text })
    , when : Optional Text
    , block : Optional (List ({ name : Text, template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool }), register : Optional Text, command : Optional Text, changed_when : Optional Text, notify : Optional Text }))
    , rescue : Optional (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }) }))
    , always : Optional (List ({ name : Text, file : Optional ({ name : Text, state : Text }), when : Optional Text, meta : Optional Text }))
  }
    , default =
        { import_role = None ({ name : Text })
    , when = None Text
    , block = None (List ({ name : Text, template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool }), register : Optional Text, command : Optional Text, changed_when : Optional Text, notify : Optional Text }))
    , rescue = None (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }) }))
    , always = None (List ({ name : Text, file : Optional ({ name : Text, state : Text }), when : Optional Text, meta : Optional Text }))
  }
    }

in  [
    Item::{ import_role = Some { name = "icos.certbot2" }, when = Some "nextcloud_certbot_enable" }
  , Item::{
      block = Some [
        {
          name = "Copy nextcloud-nginx.conf",
          template = Some {
            src = "nextcloud-nginx.conf"
          , dest = "/etc/nginx/conf.d/nextcloud.conf"
          , lstrip_blocks = True
        },
          register = Some "update",
          command = None Text,
          changed_when = None Text,
          notify = None Text
        }
      , {
          name = "Run validation",
          template = None ({ src : Text, dest : Text, lstrip_blocks : Bool }),
          register = None Text,
          command = Some "nginx -t",
          changed_when = Some "update.changed",
          notify = Some "reload nginx config"
        }
    ],
      rescue = Some [
        {
          name = "Slurp failed file and add line numbers",
          command = Some "cat -n /etc/nginx/conf.d/nextcloud.conf",
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
          , dest = "/etc/nginx/conf.d/nextcloud.conf"
          , src = "{{ update.backup_file }}"
        }
        }
    ],
      always = Some [
        {
          name = "Remove backup file",
          file = Some { name = "{{ _r.backup_file }}", state = "absent" },
          when = Some "_r['backup_file'] is defined",
          meta = None Text
        }
      , {
          name = "Flush handlers",
          file = None ({ name : Text, state : Text }),
          when = None Text,
          meta = Some "flush_handlers"
        }
    ]
    }
]
