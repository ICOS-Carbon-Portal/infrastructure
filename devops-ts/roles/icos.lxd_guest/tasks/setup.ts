import { type TaskFile } from "../../../lib/ansible/play.ts";
import { isTruthy } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install packages",
    apt: {
      update_cache: true,
      name: [
        "iptables-persistent",
      ],
    },
  },
  {
    name: "Set timezone to Europe/Stockholm",
    timezone: {
      name: "Europe/Stockholm",
    },
    notify: "restart cron",
  },
  {
    name: "Generate locale",
    locale_gen: {
      name: V.item,
      state: "present",
    },
    loop: [
      "en_US.UTF-8",
      "sv_SE.UTF-8",
    ],
  },
  {
    name: "Install public keys",
    authorized_key: {
      user: "root",
      state: "present",
      key: V.lxd_guest_root_keys,
      exclusive: true,
    },
    when: isTruthy(V.lxd_guest_root_keys),
  },
  {
    name: "Add default gateway as host",
    lineinfile: {
      path: "/etc/hosts",
      line: tmpl`${V.ansible_default_ipv4.gateway} gateway.lxd`,
      regex: "gateway.lxd$",
      state: "present",
    },
  },
  {
    import_role: "name=icos.fail2ban",
  },
] satisfies TaskFile;
