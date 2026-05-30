import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "bbservers",
    roles: [
      role("icos.bbserver").tags("bbserver"),
    ],
  },
] satisfies Playbook;
