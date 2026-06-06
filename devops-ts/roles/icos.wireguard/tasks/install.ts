import { _wg_is_installed } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  ansible_distribution,
  ansible_kernel,
  ansible_lsb,
  ansible_machine,
} from "../../../lib/builtins.ts";
import { tmpl } from "../../../lib/template.ts";
import { eq, isVersion, ne, not } from "../../../lib/vars.ts";

export default [
  {
    name: "Install wireguard for modern kernels",
    include_tasks: "wireguard-ubuntu.yml",
    when: [isVersion(ansible_kernel, "5.6", ">=")],
  },
  {
    name: "Include install tasks for raspbian",
    include_tasks: "wireguard-raspbian-zero.yml",
    when: [
      not(_wg_is_installed),
      eq(ansible_distribution, "Debian"),
      eq(ansible_lsb.id, "Raspbian"),
      eq(ansible_machine, "armv6l"),
    ],
  },
  {
    name: "Include install tasks for raspbian",
    include_tasks: "wireguard-raspbian.yml",
    when: [
      not(_wg_is_installed),
      eq(ansible_distribution, "Debian"),
      eq(ansible_lsb.id, "Raspbian"),
      ne(ansible_machine, "armv6l"),
    ],
  },
  {
    name: "Include install tasks for ubuntu",
    include_tasks: "wireguard-ubuntu.yml",
    when: [
      not(_wg_is_installed),
      eq(ansible_distribution, "Ubuntu"),
    ],
  },
  {
    name: "Fail if wireguard wasn't installed",
    fail: {
      msg:
        tmpl`Couldn't install wireguard for ${ansible_distribution}/${ansible_lsb.id}`,
    },
    when: not(_wg_is_installed),
  },
] satisfies TaskFile;
