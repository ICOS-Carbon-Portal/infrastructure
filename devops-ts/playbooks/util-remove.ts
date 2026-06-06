import { type Playbook } from "../lib/ansible/play.ts";
import { tmpl, V } from "../lib/vars.ts";

export default [
  {
    hosts: "fsicos2",
    vars: {
      nginxsite_name: "foo",
      lxd_vm_name: "foo",
    },
    tasks: [
      {
        name: tmpl`Remove nginx config for ${V.nginxsite_name}`,
        tags: "nginx",
        import_role: { name: "icos.nginxsite", tasks_from: "remove.yml" },
      },
      {
        name: tmpl`Remove lxd vm ${V.lxd_vm_name}`,
        tags: "lxd",
        import_role: { name: "icos.lxd_vm", tasks_from: "remove.yml" },
      },
    ],
  },
] satisfies Playbook;
