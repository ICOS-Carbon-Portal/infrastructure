-- Auto-generated from main.yml

{
    lxd_vm_ip = "{{ _lxd_static_ip.ip }}"
  , lxd_vm_port = "{{ hostvars[lxd_vm_inventory_hostname].ansible_port }}"
  , lxd_vm_inventory_hostname = "{{ lxd_vm_name }}"
  , lxd_vm_forward = True
  , lxd_vm_root_keys = None Text
  , lxd_vm_root_size = "50GB"
  , lxd_vm_root_pool = "{{ lxd_vm_name }}"
  , lxd_vm_docker = False
  , lxd_vm_docker_size = "50G"
  , lxd_vm_profiles = [] : List Text
  , lxd_vm_devices = {=}
  , lxd_vm_config = {=}
  , __lxd_vm_profiles = "{{ lxd_vm_default_profiles + lxd_vm_profiles }}"
  , __lxd_vm_devices = "{{ lxd_vm_default_devices | combine(_static_ip_info.devices) | combine(lxd_vm_devices)  }}"
  , __lxd_vm_config = "{{ lxd_vm_default_config | combine(lxd_vm_config)  }}"
  , lxd_vm_ubuntu_version = "22.04"
  , lxd_source = {
      type = "image"
    , mode = "pull"
    , server = "https://cloud-images.ubuntu.com/releases"
    , protocol = "simplestreams"
    , alias = "{{ lxd_vm_ubuntu_version }}"
  }
  , zfsdocker_name = "{{ lxd_vm_name }}"
}
