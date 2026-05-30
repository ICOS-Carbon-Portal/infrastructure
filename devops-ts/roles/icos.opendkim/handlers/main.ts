import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Restart opendkim",
    systemd: {
      name: "opendkim",
      state: "restarted",
    },
  },
  {
    name: "Restart postfix",
    systemd: {
      name: "postfix",
      state: "restarted",
    },
  },
] satisfies TaskFile;
