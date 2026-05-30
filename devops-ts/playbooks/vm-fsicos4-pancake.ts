import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "pancake",
    roles: [
      role("icos.pve_guest").tags("guest"),
      role("icos.utils").tags("utils"),
      role("icos.python3").tags("python3"),
    ],
  },
] satisfies Playbook;
