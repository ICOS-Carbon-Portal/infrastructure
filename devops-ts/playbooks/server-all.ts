import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "all",
    roles: [
      role("icos.server").tags("server"),
      role("icos.docker").tags("docker"),
      // role("icos.nginx").tags("nginx"),
    ],
  },
] satisfies Playbook;
