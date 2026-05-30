import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.drupal"),
    ],
  },
] satisfies Playbook;
