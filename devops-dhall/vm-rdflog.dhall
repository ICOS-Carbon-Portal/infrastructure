-- Auto-generated from vm-rdflog.yml

[
    {
      hosts = "rdflog_server",
      tags = "rdflog",
      roles = [
        {
          role = "icos.rdflog",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          tags = None Text
        }
    ]
    }
  , {
      hosts = "pgrep_rdflog_server",
      tags = "vm",
      roles = [
        {
          role = "icos.lxd_vm",
          lxd_vm_name = Some "{{ rdflog_vm_name }}",
          lxd_vm_docker = Some True,
          tags = None Text
        }
    ]
    }
  , {
      hosts = "pgrep_rdflog",
      tags = "replica",
      roles = [
        {
          role = "icos.lxd_guest",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          tags = Some "guest"
        }
      , {
          role = "icos.docker",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          tags = Some "docker"
        }
      , {
          role = "icos.pgrep",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          tags = Some "pgrep"
        }
    ]
    }
]
