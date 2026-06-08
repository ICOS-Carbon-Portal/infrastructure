import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";
import { root_keys } from "../lib/globals.ts";

export default playbook(import.meta, [
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
]);
