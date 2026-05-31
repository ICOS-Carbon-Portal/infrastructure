import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Forward ssh port and create /etc/hosts entry",
    include_role: { name: "icos.lxd_forward" },
    vars: {
      lxd_forward_name: tmpl("{{ lxd_vm_name }}"),
      lxd_forward_ip: V.lxd_vm_ip,
      lxd_forward_port: V.lxd_vm_port,
    },
  },
  {
    name: "Add local known_host",
    delegate_to: "localhost",
    known_hosts: {
      name: tmpl`[${V.inventory_hostname}]:${V.lxd_vm_port}`,
      key: tmpl`[${V.inventory_hostname}]:${V.lxd_vm_port} {{ _key.stdout}}`,
    },
  },
  {
    name: "Add vm to local ssh config",
    local_action: {
      module: "community.general.ssh_config",
      ssh_config_file: tmpl("~{{ lookup('env', 'USER') }}/.ssh/config.icos"),
      hostname: V.inventory_hostname,
      remote_user: "root",
      host: tmpl("{{ lxd_vm_name }}"),
      port: V.lxd_vm_port,
      state: "present",
    },
  },
] satisfies TaskFile;
