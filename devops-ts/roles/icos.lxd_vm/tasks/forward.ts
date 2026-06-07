import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { inventory_hostname } from "../../../lib/builtins.ts";
import { lxd_vm_name } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { lookup, tmpl } from "../../../lib/template.ts";

const _key = register("_key");

export default [
  {
    name: "Forward ssh port and create /etc/hosts entry",
    include_role: { name: "icos.lxd_forward" },
    vars: {
      lxd_forward_name: lxd_vm_name,
      lxd_forward_ip: V.lxd_vm_ip,
      lxd_forward_port: V.lxd_vm_port,
    },
  },
  {
    name: "Add local known_host",
    delegate_to: "localhost",
    known_hosts: {
      name: tmpl`[${inventory_hostname}]:${V.lxd_vm_port}`,
      key: tmpl`[${inventory_hostname}]:${V.lxd_vm_port} ${_key.stdout.ref}`,
    },
  },
  {
    name: "Add vm to local ssh config",
    local_action: {
      module: "community.general.ssh_config",
      ssh_config_file: tmpl`~${lookup("env", "USER")}/.ssh/config.icos`,
      hostname: inventory_hostname,
      remote_user: "root",
      host: lxd_vm_name,
      port: V.lxd_vm_port,
      state: "present",
    },
  },
] satisfies TaskFile;
