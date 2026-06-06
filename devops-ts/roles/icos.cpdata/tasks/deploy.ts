import { cpdata_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { cpdata_domains } from "../../../lib/globals.ts";
import { cpdata_jar_file } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { not } from "../../../lib/vars.ts";

const r = register("r");
const _r = register("_r");

export default [
  {
    name: "Add systemd service",
    template: {
      src: "cpdata.service",
      dest: "/etc/systemd/system/cpdata.service",
    },
    register: "_service",
  },
  {
    name: "Copy jarfile",
    copy: {
      src: cpdata_jar_file,
      dest: tmpl`${cpdata_home}/cpdata.jar`,
      backup: true,
    },
    register: "_jarfile",
  },
  {
    name: "Remove all but the five newest of jar file backups",
    "ansible.builtin.shell":
      `ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --
`,
    args: { chdir: cpdata_home },
    register: _r,
    changed_when: _r.stdout.startswith("removed"),
  },
  { import_tasks: "config.yml", tags: "cpdata_config" },
  {
    name: "Check that the service responds",
    uri: {
      url: tmpl`https://${cpdata_domains.first()}/buildInfo`,
      return_content: true,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
  },
] satisfies TaskFile;
