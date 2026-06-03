import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Don't create timer script in /etc/systemd/system",
    assert: {
      that: 'timer_home != "/etc/systemd/system"',
    },
    changed_when: false,
    when: raw("timer_content is defined"),
  },
  {
    name: "Create home directory",
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
      content: V.timer_content,
    },
    when: raw("timer_content is defined"),
  },
  {
    name: "Create systemd timer",
    copy: {
      dest: V._timer_sysd_timer,
      content: V.timer_config,
    },
    notify: "restart icos timer",
  },
  {
    name: "Create systemd service",
    copy: {
      dest: V._timer_sysd_service,
      content: V.timer_service,
    },
  },
  {
    name: "Link systemd files",
    when: raw('timer_home != "/etc/systemd/system"'),
    // noqa: command-instead-of-module
    command:
      tmpl`systemctl link ${V._timer_sysd_timer} ${V._timer_sysd_service}`,
    register: "_r",
    failed_when: "_r.rc != 0",
    changed_when: '"Created" in _r.stdout',
  },
  {
    name: "Start timer",
    systemd: {
      name: tmpl`${V.timer_name}.timer`,
      enabled: true,
      state: V.timer_state,
      daemon_reload: true,
    },
  },
] satisfies TaskFile;
