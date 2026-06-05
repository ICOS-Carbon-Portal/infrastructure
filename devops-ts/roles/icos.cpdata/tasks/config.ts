import {
  iff,
  or,
  register,
  type TaskFile,
  truthy,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

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
      "daemon-reload": iff(
        truthy(_service.changed).default(false),
        "yes",
        "no",
      ),
      state: iff(
        or(truthy(_jarfile.changed).default(false), _config.changed),
        "restarted",
        "started",
      ),
    },
  },
] satisfies TaskFile;
