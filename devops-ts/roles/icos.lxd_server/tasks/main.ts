import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "sysctl.yml", tags: "lxd_sysctl" },
  { import_tasks: "utils.yml", tags: "lxd_utils" },
  {
    name: "Retrieve lxd_is_snap fact",
    shellfact: {
      exec: "which lxc | grep -q '/snap/bin' && echo yes",
      fact: "lxd_is_snap",
      bool: true,
    },
  },
  // "For users of the snap, those limits are automatically raised."
  {
    name: "Modify /etc/security/limits.conf",
    when: raw("not lxd_is_snap and not ansible_check_mode"),
    tags: "lxd_limits",
    copy: {
      dest: "/etc/security/limits.conf",
      backup: true,
      content: `*    soft  nofile  1048576   unset   # max number of open files
*    hard  nofile  1048576   unset   # max number of open files
root soft  nofile  1048576   unset   # max number of open files
root hard  nofile  1048576   unset   # max number of open files
*    soft  memlock unlimited unset   # max locked-in-memory address space KB
*    hard  memlock unlimited unset   # max locked-in-memory address space KB
`,
    },
  },
] satisfies TaskFile;
