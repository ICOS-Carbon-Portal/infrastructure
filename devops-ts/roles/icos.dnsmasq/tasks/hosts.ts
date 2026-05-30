import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Populate /etc/hosts",
    blockinfile: {
      marker: tmpl`# {mark} ansible / dnsmasq / ${V.dnsmasq_config_name}`,
      state: "{{ 'present' if dnsmasq_hosts else 'absent' }}",
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: V.dnsmasq_hosts,
    },
  },
] satisfies TaskFile;
