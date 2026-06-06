import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "restart cpmeta",
    block: [
      {
        name: "Tell cpmeta to switch to readonly mode",
        uri: {
          url:
            tmpl`http://${V.cpmeta_host}}:${V.cpmeta_port}/admin/switchToReadonlyMode`,
        },
      },
      {
        name: "restart the cpmeta systemd service",
        systemd: {
          name: "cpmeta",
          state: "restarted",
        },
      },
    ],
  },
] satisfies TaskFile;
