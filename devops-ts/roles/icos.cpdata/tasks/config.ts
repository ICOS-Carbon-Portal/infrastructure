import { iff, raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create application.conf",
    copy: {
      dest: tmpl`${V.cpdata_home}/application.conf`,
      content: `{% for item in cpdata_config_files %}
# {{ item }}
{{ lookup('template', item) }}

{% endfor %}
`,
    },
    register: "_config",
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "cpdata.service",
      enabled: true,
      "daemon-reload": iff(
        raw("_service.changed | default(false)"),
        "yes",
        "no",
      ),
      state: iff(
        raw(
          "_jarfile.changed | default(false) or _config.changed",
        ),
        "restarted",
        "started",
      ),
    },
  },
] satisfies TaskFile;
