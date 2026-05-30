import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    // Multiple hosts -> rendered as the space-separated pattern "fsicos2 fsicos3 cdb".
    hosts: ["fsicos2", "fsicos3", "cdb"],
    roles: [
      role("icos.lxd_server"),
    ],
  },
] satisfies Playbook;
