-- Auto-generated from remove.yml

let Item =
    { Type =
        { name : Optional Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , loop : Optional (List Text)
    , local_action : Optional ({ module : Text, ssh_config_file : Optional Text, host : Optional Text, state : Text, name : Optional Text })
    , include_role : Optional ({ name : Text, tasks_from : Text })
    , vars : Optional ({ lxd_forward_name : Text })
    , lxd_container : Optional ({ name : Text, state : Text })
    , block : Optional (List ({ name : Text, shell : Optional Text, register : Optional Text, changed_when : Optional Text, import_role : Optional ({ name : Text, tasks_from : Text }) }))
  }
    , default =
        { name = None Text
    , fail = None ({ msg : Text })
    , when = None Text
    , loop = None (List Text)
    , local_action = None ({ module : Text, ssh_config_file : Optional Text, host : Optional Text, state : Text, name : Optional Text })
    , include_role = None ({ name : Text, tasks_from : Text })
    , vars = None ({ lxd_forward_name : Text })
    , lxd_container = None ({ name : Text, state : Text })
    , block = None (List ({ name : Text, shell : Optional Text, register : Optional Text, changed_when : Optional Text, import_role : Optional ({ name : Text, tasks_from : Text }) }))
  }
    }

in  [
    Item::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [ "lxd_vm_name" ]
    }
  , Item::{
      name = Some "Remove vm from local ssh config",
      local_action = Some {
        module = "community.general.ssh_config"
      , ssh_config_file = Some "~{{ lookup('env', 'USER') }}/.ssh/config.icos"
      , host = Some "{{ lxd_vm_name }}"
      , state = "absent"
      , name = None Text
    }
    }
  , Item::{
      name = Some "Remove local known_host",
      local_action = Some {
        module = "known_hosts"
      , ssh_config_file = None Text
      , host = None Text
      , state = "absent"
      , name = Some "[{{ inventory_hostname }}]:{{ lxd_vm_port }}"
    }
    }
  , Item::{
      name = Some "Remove ssh port forward and /etc/hosts entry",
      include_role = Some { name = "icos.lxd_forward", tasks_from = "remove.yml" },
      vars = Some { lxd_forward_name = "{{ lxd_vm_name }}" }
    }
  , Item::{
      name = Some "Remove lxd container",
      lxd_container = Some { name = "{{ lxd_vm_name }}", state = "absent" }
    }
  , Item::{
      when = Some "lxd_vm_variant == 'ext4'",
      block = Some [
        {
          name = "Delete storage pool",
          shell = Some ''
          /snap/bin/lxc storage delete {{ lxd_vm_root_pool }} || :

        '',
          register = Some "_r",
          changed_when = Some "_r.stdout.endswith('deleted')",
          import_role = None ({ name : Text, tasks_from : Text })
        }
    ]
    }
  , Item::{
      when = Some "lxd_vm_variant == 'zfs'",
      block = Some [
        {
          name = "Delete docker storage",
          shell = None Text,
          register = None Text,
          changed_when = None Text,
          import_role = Some { name = "icos.zfsdocker", tasks_from = "remove.yml" }
        }
    ]
    }
]
