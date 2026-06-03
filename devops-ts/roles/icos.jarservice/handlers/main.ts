import { type TaskFile, V } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  // Variable is not always expanded - https://github.com/ansible/ansible/issues/15505
  {
    name: tmpl`restart ${V.servicename}`,
    command: tmpl`systemctl restart ${V.servicename}`,
  },
  {
    name: "reload systemd config",
    systemd: { daemon_reload: true },
  },
  {
    name: "reload nginx config",
    // First syntax check the config. This gives us direct feedback when running
    // ansible instead of just having 'systemctl reload' (sometimes!) failing.
    command: "nginx -t",
    notify: "really reload nginx config",
  },
  {
    name: "really reload nginx config",
    service: "name=nginx state=reloaded",
  },
] satisfies TaskFile;
