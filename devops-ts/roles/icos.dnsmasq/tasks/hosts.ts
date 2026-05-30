import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Populate /etc/hosts",
    blockinfile: {
      marker: "# {mark} ansible / dnsmasq / {{ dnsmasq_config_name }}",
      state: "{{ 'present' if dnsmasq_hosts else 'absent' }}",
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: "{{ dnsmasq_hosts }}",
    },
  },
] satisfies TaskFile;
