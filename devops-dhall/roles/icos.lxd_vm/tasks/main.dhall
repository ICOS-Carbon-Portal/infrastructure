-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , include_tasks : Optional Text
    , when : Optional Text
    , lxd_static_ip_info : Optional ({ name : Text })
    , register : Optional Text
    , lxd_container : Optional ({ name : Text, state : Text, profiles : Text, source : Text, config : Text, devices : Text, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
    , lxd_static_ip : Optional ({ name : Text })
    , check_mode : Optional Bool
    , command : Optional Text
    , changed_when : Optional Text
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
    , vars : Optional ({ file : Text, keys : Text })
    , import_tasks : Optional Text
    , tags : Optional Text
  }
    , default =
        { name = None Text
    , include_tasks = None Text
    , when = None Text
    , lxd_static_ip_info = None ({ name : Text })
    , register = None Text
    , lxd_container = None ({ name : Text, state : Text, profiles : Text, source : Text, config : Text, devices : Text, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
    , lxd_static_ip = None ({ name : Text })
    , check_mode = None Bool
    , command = None Text
    , changed_when = None Text
    , retries = None Natural
    , delay = None Natural
    , until = None Text
    , vars = None ({ file : Text, keys : Text })
    , import_tasks = None Text
    , tags = None Text
  }
    }

in  [
    Item::{
      name = Some "Include tasks for ext4 variant",
      include_tasks = Some "ext4.yml",
      when = Some "lxd_vm_variant == 'ext4'"
    }
  , Item::{
      name = Some "Include tasks for zfs variant",
      include_tasks = Some "zfs.yml",
      when = Some "lxd_vm_variant == 'zfs'"
    }
  , Item::{
      name = Some "Retrieve static IP devices",
      lxd_static_ip_info = Some { name = "{{ lxd_vm_name }}" },
      register = Some "_static_ip_info"
    }
  , Item::{
      name = Some "Create container",
      register = Some "_lxd",
      lxd_container = Some {
        name = "{{ lxd_vm_name }}"
      , state = "started"
      , profiles = "{{ __lxd_vm_profiles }}"
      , source = "{{ lxd_source }}"
      , config = "{{ __lxd_vm_config }}"
      , devices = "{{ __lxd_vm_devices }}"
      , wait_for_ipv4_addresses = True
      , wait_for_ipv4_interfaces = "eth0"
      , timeout = 600
    }
    }
  , Item::{
      name = Some "Set static lxd IP",
      register = Some "_lxd_static_ip",
      lxd_static_ip = Some { name = "{{ lxd_vm_name }}" }
    }
  , Item::{
      name = Some "Extract host_ecdsa_key from the VM",
      register = Some "_key",
      check_mode = Some False,
      command = Some "lxc exec {{ lxd_vm_name }} awk '{print $1, $2}' /etc/ssh/ssh_host_ecdsa_key.pub",
      changed_when = Some "False",
      retries = Some 10,
      delay = Some 5,
      until = Some "_key.rc == 0"
    }
  , Item::{
      name = Some "Inject ssh root keys into the VM",
      register = Some "_r",
      command = Some ''
      lxc exec {{ lxd_vm_name }} -- bash -c "[ -s '{{ file }}' ] || {
                 echo '{{ keys }}' >> {{ file }};
                 echo added;
               }"
    '',
      changed_when = Some "\"added\" in _r.stdout",
      vars = Some { file = "/root/.ssh/authorized_keys", keys = "{{ lxd_vm_root_keys }}" }
    }
  , Item::{
      when = Some "lxd_vm_forward",
      import_tasks = Some "forward.yml",
      tags = Some "lxd_vm_forward"
    }
]
