import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { notVar, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install wireguard for modern kernels",
    include_tasks: "wireguard-ubuntu.yml",
    when: [raw("ansible_kernel is version('5.6', '>=')")],
  },
  {
    name: "Include install tasks for raspbian",
    include_tasks: "wireguard-raspbian-zero.yml",
    when: [
      notVar("_wg_is_installed"),
      raw('ansible_distribution == "Debian"'),
      raw('ansible_lsb.id == "Raspbian"'),
      raw('ansible_machine == "armv6l"'),
    ],
  },
  {
    name: "Include install tasks for raspbian",
    include_tasks: "wireguard-raspbian.yml",
    when: [
      notVar("_wg_is_installed"),
      raw('ansible_distribution == "Debian"'),
      raw('ansible_lsb.id == "Raspbian"'),
      raw('ansible_machine != "armv6l"'),
    ],
  },
  {
    name: "Include install tasks for ubuntu",
    include_tasks: "wireguard-ubuntu.yml",
    when: [
      notVar("_wg_is_installed"),
      raw('ansible_distribution == "Ubuntu"'),
    ],
  },
  {
    name: "Fail if wireguard wasn't installed",
    fail: {
      msg:
        tmpl`Couldn't install wireguard for ${V.ansible_distribution}/{{ ansible_lsb.id }}`,
    },
    when: notVar("_wg_is_installed"),
  },
] satisfies TaskFile;
