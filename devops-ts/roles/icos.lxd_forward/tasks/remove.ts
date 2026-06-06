import { type TaskFile } from "../../../lib/ansible/play.ts";
import { lxd_forward_name } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Modify /etc/hosts to remove lxd_forward_name.lxd",
    lineinfile: {
      path: "/etc/hosts",
      regex: tmpl`(?:.*${lxd_forward_name})\\.lxd$`,
      state: "absent",
    },
  },
  {
    name: "Remove iptables rule",
    tags: "iptables",
    iptables_raw: {
      name: tmpl`forward_ssh_to_${lxd_forward_name}`,
      table: "nat",
      state: "absent",
    },
  },
] satisfies TaskFile;
