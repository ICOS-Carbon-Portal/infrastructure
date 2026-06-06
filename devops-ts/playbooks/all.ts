import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";
import { V } from "../lib/vars.ts";

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
          key: V.root_keys,
          state: "present",
          exclusive: true,
        },
      },
    ],
  },
] satisfies Playbook;
