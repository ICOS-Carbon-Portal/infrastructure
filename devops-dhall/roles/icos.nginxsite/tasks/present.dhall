-- Auto-generated from present.yml

let Item =
    { Type =
        { name : Optional Text
    , tags : Optional Text
    , include_role : Optional ({ name : Text, apply : { tags : Text }, public : Bool })
    , when : Optional Text
    , block : Optional (List ({ name : Text, template : Optional ({ src : Text, dest : Text, backup : Bool }), register : Optional Text, file : Optional ({ dest : Text, state : Text }), shell : Optional Text, changed_when : Optional Bool, systemd : Optional ({ name : Text, state : Text }) }))
    , rescue : Optional (List ({ name : Text, copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), when : Text, file : Optional ({ path : Text, state : Text }) }))
    , always : Optional (List ({ name : Text, file : { path : Text, state : Text }, changed_when : Bool, when : Text }))
  }
    , default =
        { name = None Text
    , tags = None Text
    , include_role = None ({ name : Text, apply : { tags : Text }, public : Bool })
    , when = None Text
    , block = None (List ({ name : Text, template : Optional ({ src : Text, dest : Text, backup : Bool }), register : Optional Text, file : Optional ({ dest : Text, state : Text }), shell : Optional Text, changed_when : Optional Bool, systemd : Optional ({ name : Text, state : Text }) }))
    , rescue = None (List ({ name : Text, copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), when : Text, file : Optional ({ path : Text, state : Text }) }))
    , always = None (List ({ name : Text, file : { path : Text, state : Text }, changed_when : Bool, when : Text }))
  }
    }

in  [
    Item::{
      name = Some "Create certificates",
      tags = Some "nginxsite_cert",
      include_role = Some { name = "icos.certbot2", apply = { tags = "nginxsite_cert" }, public = True },
      when = Some "nginxsite_domains is defined"
    }
  , Item::{
      name = Some "Create basic auth users",
      tags = Some "nginxsite_users",
      include_role = Some { name = "icos.nginxauth", apply = { tags = "nginxsite_users" }, public = True },
      when = Some "nginxsite_users is defined"
    }
  , Item::{
      block = Some [
        {
          name = "Copy config",
          template = Some {
            src = "{{ nginxsite_file }}"
          , dest = "{{ nginxsite_path_confd }}"
          , backup = True
        },
          register = Some "update",
          file = None ({ dest : Text, state : Text }),
          shell = None Text,
          changed_when = None Bool,
          systemd = None ({ name : Text, state : Text })
        }
      , {
          name = "Remove old config file from sites-available",
          template = None ({ src : Text, dest : Text, backup : Bool }),
          register = None Text,
          file = Some { dest = "{{ nginxsite_path_available }}", state = "absent" },
          shell = None Text,
          changed_when = None Bool,
          systemd = None ({ name : Text, state : Text })
        }
      , {
          name = "Remove old symlink sites-enabled",
          template = None ({ src : Text, dest : Text, backup : Bool }),
          register = None Text,
          file = Some { dest = "{{ nginxsite_path_enable }}", state = "absent" },
          shell = None Text,
          changed_when = None Bool,
          systemd = None ({ name : Text, state : Text })
        }
      , {
          name = "Check syntax",
          template = None ({ src : Text, dest : Text, backup : Bool }),
          register = None Text,
          file = None ({ dest : Text, state : Text }),
          shell = Some "nginx -t",
          changed_when = Some False,
          systemd = None ({ name : Text, state : Text })
        }
      , {
          name = "Reload nginx",
          template = None ({ src : Text, dest : Text, backup : Bool }),
          register = None Text,
          file = None ({ dest : Text, state : Text }),
          shell = None Text,
          changed_when = Some False,
          systemd = Some { name = "nginx", state = "reloaded" }
        }
    ],
      rescue = Some [
        {
          name = "Restore old config",
          copy = Some { remote_src = True, dest = "{{ update.dest }}", src = "{{ update.backup_file }}" },
          when = "update.backup_file is defined",
          file = None ({ path : Text, state : Text })
        }
      , {
          name = "Remove broken config",
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          when = "update.backup_file is not defined",
          file = Some { path = "{{ update.dest }}", state = "absent" }
        }
    ],
      always = Some [
        {
          name = "Remove backup file"
        , file = { path = "{{ update.backup_file }}", state = "absent" }
        , changed_when = False
        , when = "update.backup_file is defined"
      }
    ]
    }
]
