// icos play restheart restheart_backup
import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "core_server",
    tags: "server",
    tasks: [
      {
        name: "Setup restheart proxy",
        tags: "proxy",
        import_role: { name: "icos.restheart", tasks_from: "proxy.yml" },
      },
    ],
  },
  {
    hosts: "core_host",
    tags: "host",
    roles: [
      role("icos.restheart").tags("restheart"),
    ],
  },
]);
