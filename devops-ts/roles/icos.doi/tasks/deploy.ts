import { not, register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

const r = register("r");

export default [
  {
    name: "Add systemd service",
    template: {
      src: "doi.service",
      dest: "/etc/systemd/system/doi.service",
    },
    register: "_service",
  },
  {
    name: "Create application.conf",
    template: {
      dest: tmpl`${V.doi_home}/application.conf`,
      src: "application.conf",
    },
    register: "_config",
  },
  {
    name: "Copy jarfile",
    copy: {
      src: expr("doi_jar_file"),
      dest: tmpl`${V.doi_home}/doi.jar`,
      backup: true,
    },
    register: "_jarfile",
  },
  {
    name: "Remove all but the five newest of jar file backups",
    "ansible.builtin.shell":
      `ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --
`,
    args: { chdir: V.doi_home },
    register: "_r",
    changed_when: '_r.stdout.startswith("removed")',
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "doi.service",
      enabled: true,
      "daemon-reload": expr("'yes' if _service.changed else 'no'"),
      state: expr(
        "'restarted' if _jarfile.changed or _config.changed else 'started'",
      ),
    },
  },
  {
    name: "Check that the service responds",
    uri: {
      url: tmpl`https://${expr("doi_domains | first")}/buildInfo`,
      return_content: true,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
  },
] satisfies TaskFile;
