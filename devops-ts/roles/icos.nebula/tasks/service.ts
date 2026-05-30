import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Copy nebula.service",
    template: {
      src: "nebula.service",
      dest: "/etc/systemd/system",
      lstrip_blocks: true,
    },
    notify: "restart nebula",
  },
  {
    name: "Start nebula service",
    systemd: {
      name: "nebula",
      enabled: true,
      state: "started",
      "daemon-reload": true,
    },
  },
] satisfies TaskFile;
