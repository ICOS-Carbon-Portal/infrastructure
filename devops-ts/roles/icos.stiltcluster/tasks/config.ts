import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create stiltcluster configuration file",
    template: {
      dest: "{{ stiltcluster_home }}",
      src: "local.conf",
    },
    notify: "restart stiltcluster",
  },
] satisfies TaskFile;
