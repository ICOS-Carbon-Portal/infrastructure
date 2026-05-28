-- Auto-generated from forward.yml

let Entry =
    { Type =
        { name : Text
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ lxd_forward_name : Text, lxd_forward_ip : Text, lxd_forward_port : Text })
    , delegate_to : Optional Text
    , known_hosts : Optional ({ name : Text, key : Text })
    , local_action : Optional ({ module : Text, ssh_config_file : Text, hostname : Text, remote_user : Text, host : Text, port : Text, state : Text })
  }
    , default =
        { include_role = None ({ name : Text })
    , vars = None ({ lxd_forward_name : Text, lxd_forward_ip : Text, lxd_forward_port : Text })
    , delegate_to = None Text
    , known_hosts = None ({ name : Text, key : Text })
    , local_action = None ({ module : Text, ssh_config_file : Text, hostname : Text, remote_user : Text, host : Text, port : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Forward ssh port and create /etc/hosts entry",
      include_role = Some { name = "icos.lxd_forward" },
      vars = Some {
        lxd_forward_name = "{{ lxd_vm_name }}"
      , lxd_forward_ip = "{{ lxd_vm_ip }}"
      , lxd_forward_port = "{{ lxd_vm_port }}"
    }
    }
  , Entry::{
      name = "Add local known_host",
      delegate_to = Some "localhost",
      known_hosts = Some {
        name = "[{{ inventory_hostname }}]:{{ lxd_vm_port }}"
      , key = "[{{ inventory_hostname }}]:{{ lxd_vm_port }} {{ _key.stdout}}"
    }
    }
  , Entry::{
      name = "Add vm to local ssh config",
      local_action = Some {
        module = "community.general.ssh_config"
      , ssh_config_file = "~{{ lookup('env', 'USER') }}/.ssh/config.icos"
      , hostname = "{{ inventory_hostname }}"
      , remote_user = "root"
      , host = "{{ lxd_vm_name }}"
      , port = "{{ lxd_vm_port }}"
      , state = "present"
    }
    }
]
