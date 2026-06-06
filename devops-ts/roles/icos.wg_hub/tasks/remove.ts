import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Stop and disable wg-quick",
    systemd: {
      name: tmpl`wg-quick@${V.wg_hub_intf}.service`,
      enabled: false,
      state: "stopped",
    },
  },
  {
    name: 'Remove - "Allow all inbound traffic on the wireguard interface"',
    iptables_raw: {
      name: tmpl`wireguard_${V.wg_hub_config.name}_allow_all`,
      state: "absent",
    },
  },
  {
    name: "Remove - Allow wireguard through firewall",
    when: truthy(V.wg_hub_ishub),
    iptables_raw: {
      name: tmpl`wireguard_${V.wg_hub_config.name}`,
      state: "absent",
    },
  },
  {
    name: "Remove hosts",
    blockinfile: {
      marker: tmpl`# {mark} cloud.wg_hub ${V.wg_hub_config.name}`,
      path: "/etc/hosts",
      state: "absent",
    },
  },
  {
    name: "Remove wireguard config",
    file: {
      path: tmpl`/etc/wireguard/${V.wg_hub_intf}.conf`,
      state: "absent",
    },
  },
] satisfies TaskFile;
