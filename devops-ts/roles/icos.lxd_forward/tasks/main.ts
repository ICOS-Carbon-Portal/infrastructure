import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Add iptables rule to forward lxd_forward_port",
    tags: "iptables",
    iptables_raw: {
      name: tmpl`forward_ssh_to_${V.lxd_forward_name}`,
      table: "nat",
      rules:
        tmpl`-A PREROUTING -p tcp --dport ${V.lxd_forward_port} -j DNAT --to-destination ${V.lxd_forward_ip}:22`,
    },
    when: truthy(V.lxd_forward_port),
  },
  {
    name: "Modify /etc/hosts to add lxd_forward_name.lxd",
    lineinfile: {
      path: "/etc/hosts",
      regex:
        tmpl`(?:^${V.lxd_forward_ip.regexEscape()}.*)|(?:.*${V.lxd_forward_name})\\.lxd$`,
      line: tmpl`${V.lxd_forward_ip}	${V.lxd_forward_name}.lxd`,
      state: "present",
    },
  },
] satisfies TaskFile;
