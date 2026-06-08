import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.matomo"),
    ],
  },
]);
