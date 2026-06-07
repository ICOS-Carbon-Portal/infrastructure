import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  vmagent_config_content,
  vmagent_config_dest,
} from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  { import_tasks: "assert_installed.yml" },
  {
    name: "Add a vmagent scrape config",
    copy: {
      dest: tmpl`${V.vmagent_configs}/${vmagent_config_dest}`,
      content: vmagent_config_content,
    },
    notify: "reload vmagent",
  },
] satisfies TaskFile;
