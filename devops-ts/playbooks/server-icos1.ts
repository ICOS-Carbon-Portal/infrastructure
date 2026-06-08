import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "icos1",
    roles: [
      role("icos.server").tags("server"),
      role("icos.nfs4").tags("nfs"),
      role("icos.docker2").tags("docker"),
      role("icos.lxd_server").tags("lxd_server"),
      role("icos.caddy").tags("caddy"),
    ],
  },
]);
