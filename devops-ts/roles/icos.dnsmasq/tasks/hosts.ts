import { type TaskFile } from "../../../lib/ansible/play.ts";
import { iff } from "../../../lib/template.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Populate /etc/hosts",
    blockinfile: {
      marker: tmpl`# {mark} ansible / dnsmasq / ${V.dnsmasq_config_name}`,
      state: iff(V.dnsmasq_hosts, "present", "absent"),
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: V.dnsmasq_hosts,
    },
  },
] satisfies TaskFile;
