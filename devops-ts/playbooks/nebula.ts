import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "nebula_hosts",
    roles: [
      role("icos.nebula").tags("nebula"),
    ],
  },
]);
