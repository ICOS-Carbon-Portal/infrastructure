// Upgrade certbot
//   icos play fsicos2 nginx_certbot -ecertbot_state=latest
import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.server").tags("server"),
      role("icos.docker").tags("docker"),
      role("icos.nginx").tags("nginx"),
      role("icos.bbserver").tags("bbserver"),
      role("icos.nfs4").tags("nfs"),
    ],
  },
]);
