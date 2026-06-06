import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";
import { root_keys } from "../lib/globals.ts";

export default [
  {
    hosts: "all",
    roles: [
      role("icos.utils").tags("utils"),
    ],
    tasks: [
      {
        name: "Install public key",
        tags: "root_keys",
        authorized_key: {
          user: "root",
          key: root_keys,
          state: "present",
          exclusive: true,
        },
      },
    ],
  },
] satisfies Playbook;
