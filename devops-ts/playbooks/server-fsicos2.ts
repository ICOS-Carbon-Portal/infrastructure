// Upgrade certbot
//   icos play fsicos2 nginx_certbot -ecertbot_state=latest
import { type Playbook, role } from "../lib/ansible.ts";

export default [
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
] satisfies Playbook;
