import { cpmeta_host, cpmeta_port } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "restart cpmeta",
    block: [
      {
        name: "Tell cpmeta to switch to readonly mode",
        uri: {
          url:
            tmpl`http://${cpmeta_host}}:${cpmeta_port}/admin/switchToReadonlyMode`,
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
