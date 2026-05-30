import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "dnsmasq restart",
    systemd: {
      name: "{{ dnsmasq_service_name }}",
      state: "restarted",
    },
  },
] satisfies TaskFile;
