import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Copy docker-periodic-cleanup.timer",
    copy: {
      src: "{{ item }}",
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
