import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "nebula_hosts",
    roles: [
      role("icos.nebula").tags("nebula"),
    ],
  },
] satisfies Playbook;
