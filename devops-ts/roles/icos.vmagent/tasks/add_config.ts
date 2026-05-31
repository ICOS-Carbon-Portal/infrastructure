import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  { import_tasks: "assert_installed.yml" },
  {
    name: "Add a vmagent scrape config",
    copy: {
      dest: tmpl`${V.vmagent_configs}/{{ vmagent_config_dest }}`,
      content: tmpl("{{ vmagent_config_content }}"),
    },
    notify: "reload vmagent",
  },
] satisfies TaskFile;
