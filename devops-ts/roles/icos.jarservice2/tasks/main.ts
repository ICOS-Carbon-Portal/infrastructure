import { not, raw, register, type TaskFile } from "../../../lib/ansible.ts";

const r = register("r");

export default [
  {
    import_tasks: "jarfile.yml",
    tags: "jarservice_jarfile",
    when: raw("jarservice_jar_enable | bool"),
  },
  {
    name: "Add systemd {{ jarservice_name }} servicefile",
    copy: {
      content: "{{ jarservice_unit }}",
      dest: "/etc/systemd/system/{{ jarservice_name }}.service",
    },
    notify: ["reload systemd config"],
  },
  {
    name: "Enable systemd {{ jarservice_name }}",
    service: {
      name: "{{ jarservice_name }}",
      enabled: true,
      state: "{{ jarservice_state | default('started') }}",
    },
  },
  {
    name: "Check that the service responds",
    when: raw("jarservice_check is defined"),
    uri: {
      url: "{{ jarservice_check }}",
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
