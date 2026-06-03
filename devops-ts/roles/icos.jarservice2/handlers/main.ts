import { raw, type TaskFile, V } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl`restart ${V.jarservice_name}`,
    service: {
      name: V.jarservice_name,
      state: "restarted",
    },
    when: raw("jarservice_state | default('started') == 'started'"),
  },
  {
    name: "reload systemd config",
    systemd: { daemon_reload: true },
  },
] satisfies TaskFile;
