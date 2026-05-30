import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload sshd",
    systemd: {
      name: "sshd",
      state: "reloaded",
    },
  },
] satisfies TaskFile;
