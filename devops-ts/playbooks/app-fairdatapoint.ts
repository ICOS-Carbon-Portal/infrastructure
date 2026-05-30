import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.fairdatapoint").tags("fdp"),
    ],
  },
] satisfies Playbook;
