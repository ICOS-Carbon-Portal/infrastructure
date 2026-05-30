import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Include vars for zfs",
    include_vars: "zfs.yml",
  },
  {
    name: "Create docker storage for LXD",
    when: raw("lxd_vm_docker"),
    import_role: { name: "icos.zfsdocker" },
    vars: { zfsdocker_size: "{{ lxd_vm_docker_size }}" },
  },
] satisfies TaskFile;
