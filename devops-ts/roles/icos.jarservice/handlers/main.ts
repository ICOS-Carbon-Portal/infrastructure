import { type TaskFile } from "../../../lib/ansible/play.ts";
import { servicename } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  // Variable is not always expanded - https://github.com/ansible/ansible/issues/15505
  {
    name: tmpl`restart ${servicename}`,
    command: tmpl`systemctl restart ${servicename}`,
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
