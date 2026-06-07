import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  timer_config,
  timer_content,
  timer_name,
  timer_service,
} from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { isDefined, ne } from "../../../lib/vars.ts";

export default [
  {
    name: "Don't create timer script in /etc/systemd/system",
    assert: {
      that: 'timer_home != "/etc/systemd/system"',
    },
    changed_when: false,
    when: isDefined(timer_content),
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
      content: timer_content,
    },
    when: isDefined(timer_content),
  },
  {
    name: "Create systemd timer",
    copy: {
      dest: V._timer_sysd_timer,
      content: timer_config,
    },
    notify: "restart icos timer",
  },
  {
    name: "Create systemd service",
    copy: {
      dest: V._timer_sysd_service,
      content: timer_service,
    },
  },
  {
    name: "Link systemd files",
    when: ne(V.timer_home, "/etc/systemd/system"),
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
      name: tmpl`${timer_name}.timer`,
      enabled: true,
      state: V.timer_state,
      daemon_reload: true,
    },
  },
] satisfies TaskFile;
