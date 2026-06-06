import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";
import { pattern } from "../lib/hosts.ts";

export default [
  {
    // Space-separated host pattern: "fsicos2 fsicos3 cdb".
    hosts: pattern("fsicos2", "fsicos3", "cdb"),
    roles: [
      role("icos.lxd_server"),
    ],
  },
] satisfies Playbook;
