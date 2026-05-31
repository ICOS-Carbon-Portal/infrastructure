import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl`restart ${expr("jarservice_name")}`,
    service: {
      name: expr("jarservice_name"),
      state: "restarted",
    },
    when: raw("jarservice_state | default('started') == 'started'"),
  },
  {
    name: "reload systemd config",
    systemd: { daemon_reload: true },
  },
] satisfies TaskFile;
