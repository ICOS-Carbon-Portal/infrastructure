import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { iff, tmpl } from "../../../lib/template.ts";
import { or, truthy } from "../../../lib/vars.ts";

const _service = register("_service");
const _jarfile = register("_jarfile");
const _config = register("_config");

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
    register: _config,
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "cpdata.service",
      enabled: true,
      "daemon-reload": truthy(_service.changed).default(false).asValue(),
      state: iff(
        or(truthy(_jarfile.changed).default(false), _config.changed),
        "restarted",
        "started",
      ),
    },
  },
] satisfies TaskFile;
