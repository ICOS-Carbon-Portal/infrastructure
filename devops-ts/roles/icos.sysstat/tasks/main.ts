import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Install sysstat",
    apt: {
      name: ["sysstat"],
    },
  },
  {
    name: "Enable sysstat",
    lineinfile: {
      path: "/etc/default/sysstat",
      regexp: "^ENABLED=",
      line: 'ENABLED="true"',
      state: "present",
    },
  },
  {
    name: "Start sysstat service",
    systemd: {
      name: "sysstat",
      enabled: true,
      state: "started",
    },
  },
] satisfies TaskFile;
