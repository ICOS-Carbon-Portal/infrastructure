import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

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
      name: V.item,
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
    when: truthy(V.upgrade_everything),
    notify: "reboot",
  },
] satisfies TaskFile;
