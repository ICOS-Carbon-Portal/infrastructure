import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    import_tasks: "config.yml",
    vars: {
      block: "{{ caddy_global_conf }}",
      marker: "caddy_global_conf",
      where: "BOF",
    },
  },
] satisfies TaskFile;
