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
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , caddy_name : Optional Text
        , caddy_conf : Optional Text
        , jupyter_hub_config : Optional ({ admin_users : List Text })
        , jupyter_jusers_enable : Optional Bool
        , jupyter_backup_enable : Optional Bool
        , bbclient_name : Optional Text
      }
        , default =
            { caddy_name = None Text
        , caddy_conf = None Text
        , jupyter_hub_config = None ({ admin_users : List Text })
        , jupyter_jusers_enable = None Bool
        , jupyter_backup_enable = None Bool
        , bbclient_name = None Text
      }
        }

    in  [
        Role::{
          role = "icos.caddy",
          tags = "caddy",
          caddy_name = Some "jupyter4",
          caddy_conf = Some ''
          jupyter4.icos-cp.eu {
              reverse_proxy 10.10.10.227:8000
          }

        ''
        }
    ]
    }
  , Play::{
      hosts = "fsicos4-jupyter",
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , caddy_name : Optional Text
        , caddy_conf : Optional Text
        , jupyter_hub_config : Optional ({ admin_users : List Text })
        , jupyter_jusers_enable : Optional Bool
        , jupyter_backup_enable : Optional Bool
        , bbclient_name : Optional Text
      }
        , default =
            { caddy_name = None Text
        , caddy_conf = None Text
        , jupyter_hub_config = None ({ admin_users : List Text })
        , jupyter_jusers_enable = None Bool
        , jupyter_backup_enable = None Bool
        , bbclient_name = None Text
      }
        }

    in  [
        Role::{ role = "icos.pve_guest", tags = "guest" }
      , Role::{ role = "icos.utils", tags = "utils" }
      , Role::{ role = "icos.python3", tags = "python3" }
      , Role::{ role = "icos.docker2", tags = "docker" }
      , Role::{
          role = "icos.jupyter",
          tags = "jupyter",
          jupyter_hub_config = Some { admin_users = [ "ida" ] },
          jupyter_jusers_enable = Some True,
          jupyter_backup_enable = Some False,
          bbclient_name = Some "jupyter"
        }
    ],
      tasks = Some (let Task =
        { Type =
            { name : Text
        , tags : Text
        , apt : Optional ({ name : List Text })
        , mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text })
      }
        , default =
            { apt = None ({ name : List Text })
        , mount = None ({ src : Text, path : Text, state : Text, fstype : Text })
      }
        }

    in  [
        Task::{ name = "Install nfs-common", tags = "nfs", apt = Some { name = [ "nfs-common" ] } }
      , Task::{
          name = "Mount 10.10.10.1/tank/data/ida_swift at /data/ida_swift",
          tags = "nfs",
          mount = Some {
            src = "10.10.10.1:/tank/data/ida_swift"
          , path = "/data/ida_swift"
          , state = "mounted"
          , fstype = "nfs"
        }
        }
    ])
    }
]
