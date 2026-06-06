import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "dnsmasq restart",
    systemd: {
      name: V.dnsmasq_service_name,
      state: "restarted",
    },
  },
] satisfies TaskFile;
