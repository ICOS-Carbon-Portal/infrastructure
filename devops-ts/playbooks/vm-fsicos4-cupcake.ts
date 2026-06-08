import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "cupcake",
    roles: [
      role("icos.pve_guest").tags("guest"),
      role("icos.utils").tags("utils"),
      role("icos.python3").tags("python3"),
      role("icos.docker2").tags("docker"),
    ],
  },
]);
