import { type Playbook, role } from "../lib/ansible.ts";

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
