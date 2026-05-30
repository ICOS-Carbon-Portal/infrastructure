import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Copy systemd service files",
    template: {
      src: V.item,
      dest: "/etc/systemd/system",
      lstrip_blocks: true,
    },
    loop: ["restic-server.service", "restic-server.socket"],
    notify: "restart restic",
  },
  {
    name: "Start restic socket",
    systemd: { name: "restic-server.socket", state: "started" },
  },
] satisfies TaskFile;
