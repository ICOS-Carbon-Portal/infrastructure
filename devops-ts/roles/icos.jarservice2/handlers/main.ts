import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl("restart {{ jarservice_name }}"),
    service: {
      name: tmpl("{{ jarservice_name }}"),
      state: "restarted",
    },
    when: raw("jarservice_state | default('started') == 'started'"),
  },
  {
    name: "reload systemd config",
    systemd: { daemon_reload: true },
  },
] satisfies TaskFile;
