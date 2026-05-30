import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart {{ jarservice_name }}",
    service: {
      name: "{{ jarservice_name }}",
      state: "restarted",
    },
    when: raw("jarservice_state | default('started') == 'started'"),
  },
  {
    name: "reload systemd config",
    systemd: { daemon_reload: true },
  },
] satisfies TaskFile;
