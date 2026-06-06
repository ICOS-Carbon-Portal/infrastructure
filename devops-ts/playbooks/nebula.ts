import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "nebula_hosts",
    roles: [
      role("icos.nebula").tags("nebula"),
    ],
  },
] satisfies Playbook;
