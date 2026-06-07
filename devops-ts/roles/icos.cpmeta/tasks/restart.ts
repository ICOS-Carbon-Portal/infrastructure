import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { cpmeta_domains } from "../../../lib/globals.ts";
import { _restart_needed } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { iff, tmpl } from "../../../lib/template.ts";
import { not, truthy } from "../../../lib/vars.ts";

const r = register("r");

export default [
  {
    name: "Create application.conf",
    copy: {
      dest: tmpl`${V.cpmeta_home}/application.conf`,
      content: `{% for item in cpmeta_config_files %}
# {{ item }}
{{ lookup('template', item) }}

{% endfor %}
`,
    },
    register: "_config",
  },
  {
    name: "Temporarily switch cpmeta to readonly mode before restart",
    uri: {
      method: "POST",
      url: tmpl`http://127.0.0.1:${V.cpmeta_port}/admin/switchToReadonlyMode`,
    },
    failed_when: false,
    when: truthy(_restart_needed),
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "cpmeta.service",
      enabled: true,
      state: iff(truthy(_restart_needed), "restarted", "started"),
    },
  },
  {
    name: "Check that the service responds",
    uri: {
      url: tmpl`https://${cpmeta_domains.first()}/buildInfo`,
      return_content: true,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
  },
  {
    name: "Leave cpmeta in readonly mode",
    uri: {
      method: "POST",
      url: tmpl`http://127.0.0.1:${V.cpmeta_port}/admin/switchToReadonlyMode`,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
    when: truthy(V.cpmeta_readonly_mode),
  },
] satisfies TaskFile;
