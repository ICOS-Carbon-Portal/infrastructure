import {
  iff,
  isDefined,
  not,
  or,
  register,
  type TaskFile,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const r = register("r");
const _service = register("_service");
const _config = register("_config");
const _jarfile = register("_jarfile");

export default [
  {
    name: "Add systemd service",
    template: {
      src: "stiltweb.service",
      dest: "/etc/systemd/system/stiltweb.service",
    },
    register: _service,
  },
  {
    name: "Create configuration file",
    template: { dest: tmpl`${V.stiltweb_home}/local.conf`, src: "local.conf" },
    register: _config,
  },
  {
    name: "Copy jarfile",
    when: isDefined(V.stiltweb_jar_file),
    copy: {
      src: V.stiltweb_jar_file,
      dest: tmpl`${V.stiltweb_home}/stiltweb.jar`,
      backup: true,
    },
    register: _jarfile,
  },
  {
    name: "Remove all but the five newest of jar file backups",
    "ansible.builtin.shell":
      `ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --
`,
    args: { chdir: V.stiltweb_home },
    register: "_r",
    changed_when: '_r.stdout.startswith("removed")',
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "stiltweb.service",
      enabled: true,
      "daemon-reload": iff(_service.changed, "yes", "no"),
      state: iff(
        or(_jarfile.changed, _config.changed),
        "restarted",
        "started",
      ),
    },
  },
  {
    name: "Check that the service responds",
    uri: {
      url: tmpl`https://${V.stiltweb_domains.first()}/buildInfo`,
      return_content: true,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
  },
] satisfies TaskFile;
