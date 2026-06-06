import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "bbservers",
    roles: [
      role("icos.bbserver").tags("bbserver"),
    ],
  },
] satisfies Playbook;
