import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "core_server",
    tags: "server",
    tasks: [
      {
        name: "Setup stiltweb proxy",
        tags: "proxy",
        import_role: { name: "icos.stiltweb", tasks_from: "nginx_proxy.yml" },
      },
    ],
  },
  {
    hosts: "core_host",
    tags: "host",
    vars: {
      stiltweb_akka_hostname: "fsicos2.nebula",
    },
    roles: [
      role("icos.stiltweb").tags("stiltweb"),
    ],
  },
]);
