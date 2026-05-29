-- Auto-generated from ../devops/vm-quince.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ quince_host : Text })
    , roles : List ({ name : Optional Text, tags : Optional Text, role : Text, lxd_vm_name : Optional Text, lxd_vm_root_size : Optional Text, lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text }) })
    , tasks : Optional (List ({ name : Text, tags : Text, include_role : { name : Text, apply : { tags : Text }, tasks_from : Text }, vars : { quince_name : Text, quince_domains : List Text } }))
  }
    , default =
        { vars = None ({ quince_host : Text })
    , tasks = None (List ({ name : Text, tags : Text, include_role : { name : Text, apply : { tags : Text }, tasks_from : Text }, vars : { quince_name : Text, quince_domains : List Text } }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      vars = Some { quince_host = "quince3.lxd" },
      roles = let Role =
        { Type =
            { name : Optional Text
        , tags : Optional Text
        , role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text })
      }
        , default =
            { name = None Text
        , tags = None Text
        , lxd_vm_name = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text })
      }
        }

    in  [
        Role::{
          name = Some "Create the quince3 VM",
          tags = Some "lxd",
          role = "icos.lxd_vm",
          lxd_vm_name = Some "quince3",
          lxd_vm_root_size = Some "200GB",
          lxd_vm_config = Some { `limits.cpu` = "20", `limits.memory` = "128GB" }
        }
    ],
      tasks = Some [
        {
          name = "Setup proxying for quince"
        , tags = "proxy"
        , include_role = { name = "icos.quince", apply = { tags = "proxy" }, tasks_from = "proxy.yml" }
        , vars = {
            quince_name = "quince"
          , quince_domains = [
              "quince.icos-otc.org"
            , "icoslabelling.icos-otc.org"
            , "quince-training.icos-otc.org"
          ]
        }
      }
    ]
    }
  , Play::{
      hosts = "quince3",
      roles = let Role =
        { Type =
            { name : Optional Text
        , tags : Optional Text
        , role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text })
      }
        , default =
            { name = None Text
        , tags = None Text
        , lxd_vm_name = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text })
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest" }
    ]
    }
]
