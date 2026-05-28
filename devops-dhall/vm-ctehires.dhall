-- Auto-generated from vm-ctehires.yml

let Play =
    { Type =
        { hosts : Text
    , pre_tasks : List ({ name : Text, zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { quota : Text } }), file : Optional ({ path : Text, owner : Natural, group : Natural }), `ansible.builtin.group` : Optional ({ name : Text }) })
    , roles : List ({ name : Optional Text, role : Text, lxd_vm_name : Optional Text, lxd_vm_docker : Optional Bool, lxd_vm_config : Optional ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }), lxd_vm_devices : Optional ({ ctehires : { path : Text, source : Text, type : Text } }), tags : Optional Text })
    , vars : Optional ({ user_conf : Text, user_disable_coredump : Bool })
  }
    , default =
        { vars = None ({ user_conf : Text, user_disable_coredump : Bool })
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      pre_tasks = [
        {
          name = "Create /pool/ctehires",
          zfs = Some {
            name = "pool/ctehires"
          , state = "present"
          , extra_zfs_properties = { quota = "1T" }
        },
          file = None ({ path : Text, owner : Natural, group : Natural }),
          `ansible.builtin.group` = None ({ name : Text })
        }
      , {
          name = "Change owner of /pool/ctehires",
          zfs = None ({ name : Text, state : Text, extra_zfs_properties : { quota : Text } }),
          file = Some { path = "/pool/ctehires", owner = 1000000, group = 1000000 },
          `ansible.builtin.group` = None ({ name : Text })
        }
    ],
      roles = [
        {
          name = Some "Create the ctehires VM",
          role = "icos.lxd_vm",
          lxd_vm_name = Some "ctehires",
          lxd_vm_docker = Some True,
          lxd_vm_config = Some { `security.nesting` = "true", `limits.cpu` = "16", `limits.memory` = "64GB" },
          lxd_vm_devices = Some { ctehires = { path = "/ctehires", source = "/pool/ctehires", type = "disk" } },
          tags = None Text
        }
    ]
    }
  , Play::{
      hosts = "ctehires",
      pre_tasks = [
        {
          name = "Create the ctehires group",
          zfs = None ({ name : Text, state : Text, extra_zfs_properties : { quota : Text } }),
          file = None ({ path : Text, owner : Natural, group : Natural }),
          `ansible.builtin.group` = Some { name = "ctehires" }
        }
    ],
      roles = [
        {
          name = None Text,
          role = "icos.lxd_guest",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ ctehires : { path : Text, source : Text, type : Text } }),
          tags = Some "guest"
        }
      , {
          name = None Text,
          role = "icos.docker",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ ctehires : { path : Text, source : Text, type : Text } }),
          tags = Some "docker"
        }
      , {
          name = None Text,
          role = "icos.users",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ ctehires : { path : Text, source : Text, type : Text } }),
          tags = Some "users"
        }
    ],
      vars = Some { user_conf = "{{ vault_ctehires_user_conf }}", user_disable_coredump = True }
    }
]
