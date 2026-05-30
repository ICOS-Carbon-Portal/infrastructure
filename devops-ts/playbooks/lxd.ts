import { pattern, type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    // Space-separated host pattern: "fsicos2 fsicos3 cdb".
    hosts: pattern("fsicos2", "fsicos3", "cdb"),
    roles: [
      role("icos.lxd_server"),
    ],
  },
] satisfies Playbook;
