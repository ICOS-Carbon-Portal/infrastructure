import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${V.item} needs to be defined` },
    when: raw("vars[item] is undefined"),
    loop: ["lxd_vm_name"],
  },
  {
    name: "Remove vm from local ssh config",
    local_action: {
      module: "community.general.ssh_config",
      ssh_config_file: tmpl`~${expr("lookup('env', 'USER')")}/.ssh/config.icos`,
      host: V.lxd_vm_name,
      state: "absent",
    },
  },
  {
    name: "Remove local known_host",
    local_action: {
      module: "known_hosts",
      name: tmpl`[${V.inventory_hostname}]:${V.lxd_vm_port}`,
      state: "absent",
    },
  },
  {
    name: "Remove ssh port forward and /etc/hosts entry",
    include_role: { name: "icos.lxd_forward", tasks_from: "remove.yml" },
    vars: { lxd_forward_name: V.lxd_vm_name },
  },
  {
    name: "Remove lxd container",
    lxd_container: { name: V.lxd_vm_name, state: "absent" },
  },
  {
    when: raw("lxd_vm_variant == 'ext4'"),
    block: [
      {
        name: "Delete storage pool",
        shell: tmpl`/snap/bin/lxc storage delete ${V.lxd_vm_root_pool} || :\n`,
        register: "_r",
        changed_when: "_r.stdout.endswith('deleted')",
      },
    ],
  },
  {
    when: raw("lxd_vm_variant == 'zfs'"),
    block: [
      {
        name: "Delete docker storage",
        import_role: { name: "icos.zfsdocker", tasks_from: "remove.yml" },
      },
    ],
  },
] satisfies TaskFile;
