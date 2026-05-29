-- Auto-generated from ../devops/vm-fsicos4-jupyter.yml

let Play =
    { Type =
        { hosts : Text
    , roles : List ({ role : Text, tags : Text, caddy_name : Optional Text, caddy_conf : Optional Text, jupyter_hub_config : Optional ({ admin_users : List Text }), jupyter_jusers_enable : Optional Bool, jupyter_backup_enable : Optional Bool, bbclient_name : Optional Text })
    , tasks : Optional (List ({ name : Text, tags : Text, apt : Optional ({ name : List Text }), mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text }) }))
  }
    , default =
        { tasks = None (List ({ name : Text, tags : Text, apt : Optional ({ name : List Text }), mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text }) }))
  }
    }

in  [
    Play::{
      hosts = "fsicos4",
      roles = [
        {
          role = "icos.caddy",
          tags = "caddy",
          caddy_name = Some "jupyter4",
          caddy_conf = Some ''
          jupyter4.icos-cp.eu {
              reverse_proxy 10.10.10.227:8000
          }

        '',
          jupyter_hub_config = None ({ admin_users : List Text }),
          jupyter_jusers_enable = None Bool,
          jupyter_backup_enable = None Bool,
          bbclient_name = None Text
        }
    ]
    }
  , Play::{
      hosts = "fsicos4-jupyter",
      roles = [
        {
          role = "icos.pve_guest",
          tags = "guest",
          caddy_name = None Text,
          caddy_conf = None Text,
          jupyter_hub_config = None ({ admin_users : List Text }),
          jupyter_jusers_enable = None Bool,
          jupyter_backup_enable = None Bool,
          bbclient_name = None Text
        }
      , {
          role = "icos.utils",
          tags = "utils",
          caddy_name = None Text,
          caddy_conf = None Text,
          jupyter_hub_config = None ({ admin_users : List Text }),
          jupyter_jusers_enable = None Bool,
          jupyter_backup_enable = None Bool,
          bbclient_name = None Text
        }
      , {
          role = "icos.python3",
          tags = "python3",
          caddy_name = None Text,
          caddy_conf = None Text,
          jupyter_hub_config = None ({ admin_users : List Text }),
          jupyter_jusers_enable = None Bool,
          jupyter_backup_enable = None Bool,
          bbclient_name = None Text
        }
      , {
          role = "icos.docker2",
          tags = "docker",
          caddy_name = None Text,
          caddy_conf = None Text,
          jupyter_hub_config = None ({ admin_users : List Text }),
          jupyter_jusers_enable = None Bool,
          jupyter_backup_enable = None Bool,
          bbclient_name = None Text
        }
      , {
          role = "icos.jupyter",
          tags = "jupyter",
          caddy_name = None Text,
          caddy_conf = None Text,
          jupyter_hub_config = Some { admin_users = [ "ida" ] },
          jupyter_jusers_enable = Some True,
          jupyter_backup_enable = Some False,
          bbclient_name = Some "jupyter"
        }
    ],
      tasks = Some [
        {
          name = "Install nfs-common",
          tags = "nfs",
          apt = Some { name = [ "nfs-common" ] },
          mount = None ({ src : Text, path : Text, state : Text, fstype : Text })
        }
      , {
          name = "Mount 10.10.10.1/tank/data/ida_swift at /data/ida_swift",
          tags = "nfs",
          apt = None ({ name : List Text }),
          mount = Some {
            src = "10.10.10.1:/tank/data/ida_swift"
          , path = "/data/ida_swift"
          , state = "mounted"
          , fstype = "nfs"
        }
        }
    ]
    }
]
