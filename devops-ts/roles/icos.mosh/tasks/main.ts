import { mosh_add_firewall } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Install mosh",
    apt: {
      name: [
        "mosh",
      ],
    },
  },
  {
    name: "Allow mosh through firewall",
    iptables_raw: {
      name: "allow_mosh",
      rules:
        "-A INPUT -p udp -m multiport --dports 60000:61000 -j ACCEPT -m comment --comment 'mosh'",
    },
    when: truthy(mosh_add_firewall),
  },
] satisfies TaskFile;
