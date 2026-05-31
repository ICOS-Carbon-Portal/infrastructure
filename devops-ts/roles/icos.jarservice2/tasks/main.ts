import { not, raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

const r = register("r");

export default [
  {
    import_tasks: "jarfile.yml",
    tags: "jarservice_jarfile",
    when: raw("jarservice_jar_enable | bool"),
  },
  {
    name: tmpl`Add systemd ${expr("jarservice_name")} servicefile`,
    copy: {
      content: expr("jarservice_unit"),
      dest: tmpl`/etc/systemd/system/${expr("jarservice_name")}.service`,
    },
    notify: ["reload systemd config"],
  },
  {
    name: tmpl`Enable systemd ${expr("jarservice_name")}`,
    service: {
      name: expr("jarservice_name"),
      enabled: true,
      state: expr("jarservice_state | default('started')"),
    },
  },
  {
    name: "Check that the service responds",
    when: raw("jarservice_check is defined"),
    uri: {
      url: expr("jarservice_check"),
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
      raw("jarservice_check is defined"),
      raw("jarservice_githash is defined"),
    ],
  },
] satisfies TaskFile;
