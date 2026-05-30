import { not, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const r = register("r");

export default [
  {
    name: "Add systemd service",
    template: {
      src: "cpauth.service",
      dest: "/etc/systemd/system/cpauth.service",
    },
    register: "_service",
  },
  {
    name: "Create application.conf",
    copy: {
      dest: tmpl`${V.cpauth_home}/application.conf`,
      content: `{% for item in cpauth_config_files %}
# {{ item }}
{{ lookup('template', item) }}

{% endfor %}
`,
    },
    register: "_config",
  },
  {
    name: "Copy jarfile",
    copy: {
      src: "{{ cpauth_jar_file }}",
      dest: tmpl`${V.cpauth_home}/cpauth.jar`,
      backup: true,
    },
    register: "_jarfile",
  },
  {
    name: "Remove all but the five newest of jar file backups",
    "ansible.builtin.shell":
      `ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --
`,
    args: { chdir: V.cpauth_home },
    register: "_r",
    changed_when: '_r.stdout.startswith("removed")',
  },
  {
    name: "Start/restart service",
    systemd: {
      name: "cpauth.service",
      enabled: true,
      "daemon-reload": "{{ 'yes' if _service.changed else 'no' }}",
      state:
        "{{ 'restarted' if _jarfile.changed or _config.changed else 'started' }}",
    },
  },
  {
    name: "Check that the service responds",
    uri: {
      url: "https://{{ cpauth_domains | first }}/buildInfo",
      return_content: true,
    },
    register: r,
    failed_when: r.failed,
    retries: 30,
    delay: 10,
    until: not(r.failed),
  },
] satisfies TaskFile;
