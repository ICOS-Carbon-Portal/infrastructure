import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Include tasks for ext4 variant",
    include_tasks: "ext4.yml",
    when: raw("lxd_vm_variant == 'ext4'"),
  },
  {
    name: "Include tasks for zfs variant",
    include_tasks: "zfs.yml",
    when: raw("lxd_vm_variant == 'zfs'"),
  },
  {
    name: "Retrieve static IP devices",
    lxd_static_ip_info: { name: "{{ lxd_vm_name }}" },
    register: "_static_ip_info",
  },
  {
    name: "Create container",
    lxd_container: {
      name: "{{ lxd_vm_name }}",
      state: "started",
      profiles: "{{ __lxd_vm_profiles }}",
      source: "{{ lxd_source }}",
      config: "{{ __lxd_vm_config }}",
      devices: "{{ __lxd_vm_devices }}",
      wait_for_ipv4_addresses: true,
      wait_for_ipv4_interfaces: "eth0",
      timeout: 600,
    },
    register: "_lxd",
  },
  {
    name: "Set static lxd IP",
    lxd_static_ip: { name: "{{ lxd_vm_name }}" },
    register: "_lxd_static_ip",
  },
  {
    name: "Extract host_ecdsa_key from the VM",
    check_mode: false,
    command:
      "lxc exec {{ lxd_vm_name }} awk '{print $1, $2}' /etc/ssh/ssh_host_ecdsa_key.pub",
    register: "_key",
    changed_when: false,
    retries: 10,
    delay: 5,
    until: "_key.rc == 0",
  },
  {
    name: "Inject ssh root keys into the VM",
    command:
      `lxc exec {{ lxd_vm_name }} -- bash -c "[ -s '{{ file }}' ] || {\n           echo '{{ keys }}' >> {{ file }};\n           echo added;\n         }"`,
    vars: {
      file: "/root/.ssh/authorized_keys",
      keys: "{{ lxd_vm_root_keys }}",
    },
    register: "_r",
    changed_when: '"added" in _r.stdout',
  },
  {
    import_tasks: "forward.yml",
    tags: "lxd_vm_forward",
    when: raw("lxd_vm_forward"),
  },
] satisfies TaskFile;
