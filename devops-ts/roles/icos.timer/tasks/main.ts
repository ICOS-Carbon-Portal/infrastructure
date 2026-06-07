import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_check_mode } from "../../../lib/builtins.ts";
import { timer_content, timer_name } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { isDefined, ne, not } from "../../../lib/vars.ts";

export default [
  {
    name: "Don't create timer script in /etc/systemd/system",
    assert: {
      that: 'timer_home != "/etc/systemd/systemd"',
    },
    changed_when: false,
    when: isDefined(timer_content),
  },
  {
    name: "Create home directory",
    when: ne(V.timer_home, "/etc/systemd/systemd"),
    file: {
      path: V.timer_home,
      state: "directory",
    },
  },
  {
    name: "Create timer script",
    copy: {
      dest: V.timer_dest,
      mode: "+x",
      content: timer_content,
    },
    when: isDefined(timer_content),
  },
  {
    name: "Create systemd timer definition",
    copy: {
      dest: V._timer_sysd_timer,
      content: `[Unit]
Description={{ timer_desc }}

[Timer]
{{ timer_conf }}

[Install]
WantedBy=timers.target
`,
    },
    notify: "restart icos timer",
  },
  {
    name: "Create systemd service",
    copy: {
      dest: V._timer_sysd_service,
      content: `[Unit]
Description={{ timer_desc }}

[Service]
User={{ timer_user }}
Type=oneshot
ExecStart={{ timer_exec }}
{% for env in timer_envs | default([]) -%}
Environment={{ env }}
{% endfor -%}
{% if timer_wdir %}
WorkingDirectory={{ timer_wdir }}
{% endif %}
`,
    },
  },
  {
    name: "Link systemd files",
    when: ne(V.timer_home, "/etc/systemd/system"),
    command:
      tmpl`systemctl link ${V._timer_sysd_timer} ${V._timer_sysd_service}`,
    register: "_r",
    failed_when: "_r.rc != 0",
    changed_when: '"Created" in _r.stdout',
  },
  {
    name: "Start timer",
    when: not(ansible_check_mode),
    systemd: {
      name: tmpl`${timer_name}.timer`,
      enabled: true,
      state: "started",
      daemon_reload: true,
    },
  },
] satisfies TaskFile;
