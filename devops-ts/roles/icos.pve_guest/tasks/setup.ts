import { upgrade_everything } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Install qemu-guest-agent",
    apt: {
      update_cache: true,
      name: [
        // This one enables interaction with the proxmox host.
        "qemu-guest-agent",
      ],
    },
    notify: "reboot",
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
    name: "Upgrade everything",
    apt: {
      update_cache: true,
      upgrade: true,
      autoclean: true,
      autoremove: true,
    },
    when: truthy(upgrade_everything),
    notify: "reboot",
  },
] satisfies TaskFile;
