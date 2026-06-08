import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "all",
    roles: [
      role("icos.server").tags("server"),
      role("icos.docker").tags("docker"),
      // role("icos.nginx").tags("nginx"),
    ],
  },
]);
