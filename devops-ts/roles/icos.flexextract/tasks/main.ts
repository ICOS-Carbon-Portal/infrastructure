import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create flexextract user",
    user: {
      name: V.flexextract_user,
      home: expr("flexextract_home | default(omit)"),
      shell: "/bin/bash",
      groups: "docker",
      append: true,
    },
  },
  {
    name: "Add passwordless sudo for flexextract",
    copy: {
      dest: "/etc/sudoers.d/flexextract",
      content: "flexextract ALL = NOPASSWD: ALL\n",
    },
  },
  {
    import_tasks: "flexextract.yml",
    become: true,
    become_user: "flexextract",
  },
] satisfies TaskFile;
