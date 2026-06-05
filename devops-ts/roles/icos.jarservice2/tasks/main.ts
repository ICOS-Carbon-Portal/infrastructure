import {
  isDefined,
  not,
  register,
  type TaskFile,
  truthy,
  V,
} from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

const r = register("r");

export default [
  {
    import_tasks: "jarfile.yml",
    tags: "jarservice_jarfile",
    when: truthy(V.jarservice_jar_enable).bool(),
  },
  {
    name: tmpl`Add systemd ${V.jarservice_name} servicefile`,
    copy: {
      content: V.jarservice_unit,
      dest: tmpl`/etc/systemd/system/${V.jarservice_name}.service`,
    },
    notify: ["reload systemd config"],
  },
  {
    name: tmpl`Enable systemd ${V.jarservice_name}`,
    service: {
      name: V.jarservice_name,
      enabled: true,
      state: V.jarservice_state.default("started"),
    },
  },
  {
    name: "Check that the service responds",
    when: isDefined(V.jarservice_check),
    uri: {
      url: V.jarservice_check,
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
      isDefined(V.jarservice_check),
      isDefined(V.jarservice_githash),
    ],
  },
] satisfies TaskFile;
