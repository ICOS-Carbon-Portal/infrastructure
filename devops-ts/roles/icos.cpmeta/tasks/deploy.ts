import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Copy jarfile",
    copy: {
      src: tmpl("{{ cpmeta_jar_file }}"),
      dest: tmpl`${V.cpmeta_home}/cpmeta.jar`,
      backup: true,
    },
    register: "_jarfile",
  },
  {
    name: "Remove all but the five newest of jar file backups",
    "ansible.builtin.shell":
      `ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --
`,
    args: { chdir: V.cpmeta_home },
    register: "_r",
    changed_when: '_r.stdout.startswith("removed")',
  },
  {
    include_tasks: "restart.yml",
    vars: {
      _restart_needed: tmpl("{{ _config.changed or _jarfile.changed }}"),
    },
  },
] satisfies TaskFile;
