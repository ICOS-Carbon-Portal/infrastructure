-- Auto-generated from ../devops/vm-rdflog.yml

[
    {
      hosts = "rdflog_server",
      tags = "rdflog",
      roles = let Role =
        { Type =
            { role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_docker : Optional Bool
        , tags : Optional Text
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_docker = None Bool
        , tags = None Text
      }
        }

    in  [
        Role::{ role = "icos.rdflog" }
    ]
    }
  , {
      hosts = "pgrep_rdflog_server",
      tags = "vm",
      roles = let Role =
        { Type =
            { role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_docker : Optional Bool
        , tags : Optional Text
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_docker = None Bool
        , tags = None Text
      }
        }

    in  [
        Role::{
          role = "icos.lxd_vm",
          lxd_vm_name = Some "{{ rdflog_vm_name }}",
          lxd_vm_docker = Some True
        }
    ]
    }
  , {
      hosts = "pgrep_rdflog",
      tags = "replica",
      roles = let Role =
        { Type =
            { role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_docker : Optional Bool
        , tags : Optional Text
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_docker = None Bool
        , tags = None Text
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = Some "guest" }
      , Role::{ role = "icos.docker", tags = Some "docker" }
      , Role::{ role = "icos.pgrep", tags = Some "pgrep" }
    ]
    }
]
