import { type Playbook, role } from "../lib/ansible.ts";

export default [
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
] satisfies Playbook;
