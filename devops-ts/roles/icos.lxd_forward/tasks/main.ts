import { lxd_forward_port } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { lxd_forward_ip, lxd_forward_name } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Add iptables rule to forward lxd_forward_port",
    tags: "iptables",
    iptables_raw: {
      name: tmpl`forward_ssh_to_${lxd_forward_name}`,
      table: "nat",
      rules:
        tmpl`-A PREROUTING -p tcp --dport ${lxd_forward_port} -j DNAT --to-destination ${lxd_forward_ip}:22`,
    },
    when: truthy(lxd_forward_port),
  },
  {
    name: "Modify /etc/hosts to add lxd_forward_name.lxd",
    lineinfile: {
      path: "/etc/hosts",
      regex:
        tmpl`(?:^${lxd_forward_ip.regexEscape()}.*)|(?:.*${lxd_forward_name})\\.lxd$`,
      line: tmpl`${lxd_forward_ip}	${lxd_forward_name}.lxd`,
      state: "present",
    },
  },
] satisfies TaskFile;
