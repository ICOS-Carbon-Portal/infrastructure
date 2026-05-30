import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart cpmeta",
    block: [
      {
        name: "Tell cpmeta to switch to readonly mode",
        uri: {
          url:
            "http://{{ cpmeta_host }}}:{{ cpmeta_port }}/admin/switchToReadonlyMode",
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
