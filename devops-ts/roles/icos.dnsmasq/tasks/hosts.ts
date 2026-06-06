import { dnsmasq_config_name, dnsmasq_hosts } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { iff, tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Populate /etc/hosts",
    blockinfile: {
      marker: tmpl`# {mark} ansible / dnsmasq / ${dnsmasq_config_name}`,
      state: iff(dnsmasq_hosts, "present", "absent"),
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: dnsmasq_hosts,
    },
  },
] satisfies TaskFile;
