import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_default_ipv4, item } from "../../../lib/builtins.ts";
import { lxd_guest_root_keys } from "../../../lib/globals.ts";
import { tmpl } from "../../../lib/template.ts";
import { isTruthy } from "../../../lib/vars.ts";

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
      name: item,
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
      key: lxd_guest_root_keys,
      exclusive: true,
    },
    when: isTruthy(lxd_guest_root_keys),
  },
  {
    name: "Add default gateway as host",
    lineinfile: {
      path: "/etc/hosts",
      line: tmpl`${ansible_default_ipv4.gateway} gateway.lxd`,
      regex: "gateway.lxd$",
      state: "present",
    },
  },
  {
    import_role: "name=icos.fail2ban",
  },
] satisfies TaskFile;
