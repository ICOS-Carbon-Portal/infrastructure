import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Copy docker-periodic-cleanup.timer",
    copy: {
      src: V.item,
      dest: "/etc/systemd/system",
    },
    loop: ["docker-periodic-cleanup.timer", "docker-periodic-cleanup.service"],
  },
  {
    name: "Start docker-periodic-cleanup.timer",
    systemd: {
      name: "docker-periodic-cleanup.timer",
      enabled: true,
      state: "started",
      daemon_reload: true,
    },
  },
] satisfies TaskFile;
