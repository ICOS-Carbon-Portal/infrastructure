import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  { import_tasks: "assert_installed.yml" },
  {
    name: "Add a vmagent scrape config",
    copy: {
      dest: tmpl`${V.vmagent_configs}/${expr("vmagent_config_dest")}`,
      content: expr("vmagent_config_content"),
    },
    notify: "reload vmagent",
  },
] satisfies TaskFile;
