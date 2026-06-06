import { type TaskFile } from "../../../lib/ansible/play.ts";
import { eq, truthy } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl`restart ${V.jarservice_name}`,
    service: {
      name: V.jarservice_name,
      state: "restarted",
    },
    when: eq(truthy(V.jarservice_state).default("started"), "started"),
  },
  {
    name: "reload systemd config",
    systemd: { daemon_reload: true },
  },
] satisfies TaskFile;
