import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create application.conf",
    copy: {
      dest: "{{ cpdata_home }}/application.conf",
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
      "daemon-reload":
        "{{ 'yes' if _service.changed | default(false) else 'no' }}",
      state:
        "{{ 'restarted' if _jarfile.changed | default(false) or _config.changed else 'started' }}",
    },
  },
] satisfies TaskFile;
