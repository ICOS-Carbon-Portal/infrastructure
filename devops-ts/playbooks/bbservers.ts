import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "bbservers",
    roles: [
      role("icos.bbserver").tags("bbserver"),
    ],
  },
]);
