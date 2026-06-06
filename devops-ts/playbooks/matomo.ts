import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.matomo"),
    ],
  },
] satisfies Playbook;
