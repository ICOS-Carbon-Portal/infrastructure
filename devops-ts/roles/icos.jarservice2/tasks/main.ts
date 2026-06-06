import { jarservice_jar_enable } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  jarservice_check,
  jarservice_githash,
  jarservice_name,
  jarservice_state,
  jarservice_unit,
} from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { isDefined, not, truthy } from "../../../lib/vars.ts";

const r = register("r");

export default [
  {
    import_tasks: "jarfile.yml",
    tags: "jarservice_jarfile",
    when: truthy(jarservice_jar_enable).bool(),
  },
  {
    name: tmpl`Add systemd ${jarservice_name} servicefile`,
    copy: {
      content: jarservice_unit,
      dest: tmpl`/etc/systemd/system/${jarservice_name}.service`,
    },
    notify: ["reload systemd config"],
  },
  {
    name: tmpl`Enable systemd ${jarservice_name}`,
    service: {
      name: jarservice_name,
      enabled: true,
      state: jarservice_state.default("started"),
    },
  },
  {
    name: "Check that the service responds",
    when: isDefined(jarservice_check),
    uri: {
      url: jarservice_check,
      return_content: true,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
  },
  {
    name: "Check that the gitHash is correct",
    assert: {
      that: ["jarservice_githash in r.content"],
    },
    when: [
      isDefined(jarservice_check),
      isDefined(jarservice_githash),
    ],
  },
] satisfies TaskFile;
