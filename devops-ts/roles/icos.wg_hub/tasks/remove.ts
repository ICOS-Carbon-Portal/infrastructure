import { wg_hub_intf, wg_hub_ishub } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { wg_hub_config } from "../../../lib/globals.ts";
import { tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Stop and disable wg-quick",
    systemd: {
      name: tmpl`wg-quick@${wg_hub_intf}.service`,
      enabled: false,
      state: "stopped",
    },
  },
  {
    name: 'Remove - "Allow all inbound traffic on the wireguard interface"',
    iptables_raw: {
      name: tmpl`wireguard_${wg_hub_config.name}_allow_all`,
      state: "absent",
    },
  },
  {
    name: "Remove - Allow wireguard through firewall",
    when: truthy(wg_hub_ishub),
    iptables_raw: {
      name: tmpl`wireguard_${wg_hub_config.name}`,
      state: "absent",
    },
  },
  {
    name: "Remove hosts",
    blockinfile: {
      marker: tmpl`# {mark} cloud.wg_hub ${wg_hub_config.name}`,
      path: "/etc/hosts",
      state: "absent",
    },
  },
  {
    name: "Remove wireguard config",
    file: {
      path: tmpl`/etc/wireguard/${wg_hub_intf}.conf`,
      state: "absent",
    },
  },
] satisfies TaskFile;
