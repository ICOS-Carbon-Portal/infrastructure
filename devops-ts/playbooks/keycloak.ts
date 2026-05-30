import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.keycloak", { kc_hostname: "keycloak.icos-cp.eu" }),
    ],
  },
] satisfies Playbook;
