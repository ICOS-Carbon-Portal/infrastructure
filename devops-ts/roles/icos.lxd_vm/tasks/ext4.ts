import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Include vars for ext4",
    include_vars: "ext4.yml",
  },
  {
    name: "Create {{ lxd_vm_root_pool }} storage pool",
    tags: "pool",
    shell:
      "/snap/bin/lxc storage show {{ lxd_vm_root_pool }} > /dev/null 2>&1 || \\ /snap/bin/lxc storage create {{ lxd_vm_root_pool }} \\\n                      btrfs size={{ lxd_vm_root_size }}\n",
    register: "_r",
    changed_when: [
      '("Storage pool %s created" % lxd_vm_root_pool) in _r.stdout',
    ],
  },
] satisfies TaskFile;
