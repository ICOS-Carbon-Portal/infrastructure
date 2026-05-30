import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create application.conf",
    copy: {
      dest: "{{ cpmeta_home }}/application.conf",
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
      url: "http://127.0.0.1:{{ cpmeta_port }}/admin/switchToReadonlyMode",
    },
    failed_when: false,
    when: raw("_restart_needed"),
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "cpmeta.service",
      enabled: true,
      state: "{{ 'restarted' if _restart_needed else 'started' }}",
    },
  },
  {
    name: "Check that the service responds",
    uri: {
      url: "https://{{ cpmeta_domains | first }}/buildInfo",
      return_content: true,
    },
    register: "r",
    failed_when: "r.failed",
    retries: 30,
    delay: 10,
    until: "not r.failed",
  },
  {
    name: "Leave cpmeta in readonly mode",
    uri: {
      method: "POST",
      url: "http://127.0.0.1:{{ cpmeta_port }}/admin/switchToReadonlyMode",
    },
    register: "r",
    failed_when: "r.failed",
    retries: 30,
    delay: 10,
    until: "not r.failed",
    when: raw("cpmeta_readonly_mode"),
  },
] satisfies TaskFile;
