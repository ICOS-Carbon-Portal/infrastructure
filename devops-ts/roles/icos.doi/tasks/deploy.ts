import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { iff } from "../../../lib/template.ts";
import { not, or } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

const r = register("r");
const _service = register("_service");
const _config = register("_config");
const _jarfile = register("_jarfile");
const _r = register("_r");

export default [
  {
    name: "Add systemd service",
    template: {
      src: "doi.service",
      dest: "/etc/systemd/system/doi.service",
    },
    register: _service,
  },
  {
    name: "Create application.conf",
    template: {
      dest: tmpl`${V.doi_home}/application.conf`,
      src: "application.conf",
    },
    register: _config,
  },
  {
    name: "Copy jarfile",
    copy: {
      src: V.doi_jar_file,
      dest: tmpl`${V.doi_home}/doi.jar`,
      backup: true,
    },
    register: _jarfile,
  },
  {
    name: "Remove all but the five newest of jar file backups",
    "ansible.builtin.shell":
      `ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --
`,
    args: { chdir: V.doi_home },
    register: _r,
    changed_when: _r.stdout.startswith("removed"),
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "doi.service",
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
      url: tmpl`https://${V.doi_domains.first()}/buildInfo`,
      return_content: true,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
  },
] satisfies TaskFile;
