import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart nfs-kernel-server",
    systemd: {
      name: "nfs-kernel-server",
      state: "restarted",
      "daemon-reload": true,
    },
  },
] satisfies TaskFile;
