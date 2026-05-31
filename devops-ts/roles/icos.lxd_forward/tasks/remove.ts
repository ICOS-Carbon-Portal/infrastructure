import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Modify /etc/hosts to remove lxd_forward_name.lxd",
    lineinfile: {
      path: "/etc/hosts",
      regex: tmpl`(?:.*${expr("lxd_forward_name")})\\.lxd$`,
      state: "absent",
    },
  },
  {
    name: "Remove iptables rule",
    tags: "iptables",
    iptables_raw: {
      name: tmpl`forward_ssh_to_${expr("lxd_forward_name")}`,
      table: "nat",
      state: "absent",
    },
  },
] satisfies TaskFile;
