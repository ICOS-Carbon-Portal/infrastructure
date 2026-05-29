-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Include tasks for ext4 variant",
      include_tasks = Some "ext4.yml",
      when = Some [ "lxd_vm_variant == 'ext4'" ]
    }
  , Task::{
      name = Some "Include tasks for zfs variant",
      include_tasks = Some "zfs.yml",
      when = Some [ "lxd_vm_variant == 'zfs'" ]
    }
  , Task::{
      name = Some "Retrieve static IP devices",
      lxd_static_ip_info = Some { name = "{{ lxd_vm_name }}" },
      register = Some "_static_ip_info"
    }
  , Task::{
      name = Some "Create container",
      lxd_container = Some {
        name = "{{ lxd_vm_name }}"
      , state = "started"
      , profiles = Some "{{ __lxd_vm_profiles }}"
      , source = Some "{{ lxd_source }}"
      , config = Some "{{ __lxd_vm_config }}"
      , devices = Some "{{ __lxd_vm_devices }}"
      , wait_for_ipv4_addresses = Some True
      , wait_for_ipv4_interfaces = Some "eth0"
      , timeout = Some 600
    },
      register = Some "_lxd"
    }
  , Task::{
      name = Some "Set static lxd IP",
      lxd_static_ip = Some { name = "{{ lxd_vm_name }}" },
      register = Some "_lxd_static_ip"
    }
  , Task::{
      name = Some "Extract host_ecdsa_key from the VM",
      check_mode = Some False,
      command = Some "lxc exec {{ lxd_vm_name }} awk '{print $1, $2}' /etc/ssh/ssh_host_ecdsa_key.pub",
      register = Some "_key",
      changed_when = Some "False",
      retries = Some 10,
      delay = Some 5,
      until = Some "_key.rc == 0"
    }
  , Task::{
      name = Some "Inject ssh root keys into the VM",
      command = Some ''
      lxc exec {{ lxd_vm_name }} -- bash -c "[ -s '{{ file }}' ] || {
                 echo '{{ keys }}' >> {{ file }};
                 echo added;
               }"
    '',
      vars = Some {
        timer_home = None Text
      , timer_exec = None Text
      , timer_name = None Text
      , timer_conf = None Text
      , timer_envs = None (List Text)
      , timer_content = None Text
      , timer_user = None Text
      , block = None Text
      , marker = None Text
      , where = None Text
      , state = None Text
      , bbclient_name = None Text
      , bbclient_user = None Text
      , bbclient_home = None Text
      , bbclient_timer_conf = None Text
      , bbclient_timer_content = None Text
      , certbot_name = None Text
      , certbot_domains = None (List Text)
      , nginxsite_name = None Text
      , nginxsite_file = None Text
      , _restart_needed = None Text
      , fail2ban_config_files = None (List ({ dest : Text, content : Text }))
      , nginxauth_file = None Text
      , nginxauth_users = None Text
      , jarservice_name = None Text
      , jarservice_home = None Text
      , jarservice_local = None Text
      , jarservice_unit = None Text
      , nginxsite_domains = None (List Text)
      , jupyter_cert_name = None Text
      , conf = None Text
      , lxd_forward_name = None Text
      , lxd_forward_ip = None Text
      , lxd_forward_port = None Text
      , file = Some "/root/.ssh/authorized_keys"
      , keys = Some "{{ lxd_vm_root_keys }}"
      , zfsdocker_size = None Text
      , set_fact = None Text
      , file_var = None Text
      , python_util_src = None Text
      , nginxauth_name = None Text
      , dbin_download_dest = None Text
      , dbin_user = None Text
      , dbin_repo = None Text
      , dbin_path = None Text
      , dbin_arch = None Text
      , timer_wdir = None Text
      , vmagent_config_dest = None Text
      , vmagent_config_content = None Text
      , dbin_src = None Text
      , dbin_url = None Text
      , _builtin_version = None Text
      , nginxauth_conf = None Text
      , nginxsite_users = None (List Text)
      , dbin_unar = None Bool
      , timer_state = None Text
      , timer_config = None Text
      , timer_service = None Text
    },
      register = Some "_r",
      changed_when = Some "\"added\" in _r.stdout"
    }
  , Task::{
      import_tasks = Some "forward.yml",
      tags = Some [ "lxd_vm_forward" ],
      when = Some [ "lxd_vm_forward" ]
    }
]
