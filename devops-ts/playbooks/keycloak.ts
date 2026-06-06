import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.keycloak", { kc_hostname: "keycloak.icos-cp.eu" }),
    ],
  },
] satisfies Playbook;
