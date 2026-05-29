-- Auto-generated from ../devops/vm-staging.yml

let Play =
    { Type =
        { hosts : Text
    , pre_tasks : Optional (List ({ name : Text, tags : Text, file : { path : Text, state : Text, owner : Natural, group : Natural } }))
    , roles : List ({ role : Text, tags : Text, lxd_vm_name : Optional Text, lxd_vm_docker : Optional Bool, lxd_vm_root_size : Optional Text, lxd_vm_devices : Optional ({ dataprod : { path : Text, source : Text, type : Text, readonly : Text }, staging : { path : Text, source : Text, type : Text } }) })
  }
    , default =
        { pre_tasks = None (List ({ name : Text, tags : Text, file : { path : Text, state : Text, owner : Natural, group : Natural } }))
  }
    }

in  [
    Play::{
      hosts = "staging_server",
      pre_tasks = Some [
        {
          name = "Create  directory"
        , tags = "vm"
        , file = {
            path = "/disk/data/staging"
          , state = "directory"
          , owner = 1000000
          , group = 1000000
        }
      }
    ],
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_docker : Optional Bool
        , lxd_vm_root_size : Optional Text
        , lxd_vm_devices : Optional ({ dataprod : { path : Text, source : Text, type : Text, readonly : Text }, staging : { path : Text, source : Text, type : Text } })
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_docker = None Bool
        , lxd_vm_root_size = None Text
        , lxd_vm_devices = None ({ dataprod : { path : Text, source : Text, type : Text, readonly : Text }, staging : { path : Text, source : Text, type : Text } })
      }
        }

    in  [
        Role::{
          role = "icos.lxd_vm",
          tags = "vm",
          lxd_vm_name = Some "staging",
          lxd_vm_docker = Some True,
          lxd_vm_root_size = Some "200GB",
          lxd_vm_devices = Some {
            dataprod = {
              path = "/data/dataAppStorage/"
            , source = "/disk/data/dataAppStorage/"
            , type = "disk"
            , readonly = "true"
          }
          , staging = { path = "/data/staging", source = "/disk/data/staging", type = "disk" }
        }
        }
    ]
    }
  , Play::{
      hosts = "staging",
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_docker : Optional Bool
        , lxd_vm_root_size : Optional Text
        , lxd_vm_devices : Optional ({ dataprod : { path : Text, source : Text, type : Text, readonly : Text }, staging : { path : Text, source : Text, type : Text } })
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_docker = None Bool
        , lxd_vm_root_size = None Text
        , lxd_vm_devices = None ({ dataprod : { path : Text, source : Text, type : Text, readonly : Text }, staging : { path : Text, source : Text, type : Text } })
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = "guest" }
      , Role::{ role = "icos.docker", tags = "docker" }
      , Role::{ role = "icos.restheart", tags = "restheart" }
    ]
    }
]
