import { dnsmasq_service_name } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "dnsmasq restart",
    systemd: {
      name: dnsmasq_service_name,
      state: "restarted",
    },
  },
] satisfies TaskFile;
