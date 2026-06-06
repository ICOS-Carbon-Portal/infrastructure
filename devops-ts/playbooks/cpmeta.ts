import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "core_server",
    tags: "server",
    tasks: [
      {
        name: "Setup cpmeta proxy",
        tags: "proxy",
        import_role: { name: "icos.cpmeta", tasks_from: "proxy.yml" },
      },
    ],
  },
  {
    hosts: "core_host",
    tags: "host",
    roles: [
      role("icos.cpmeta"),
    ],
  },
] satisfies Playbook;
