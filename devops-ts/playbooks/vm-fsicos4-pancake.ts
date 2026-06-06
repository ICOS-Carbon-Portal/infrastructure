import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

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
