import { type Playbook } from "../lib/ansible/play.ts";
import { lxd_vm_name } from "../lib/paramvars.ts";
import { nginxsite_name } from "../lib/sharedvars.ts";
import { tmpl } from "../lib/vars.ts";

export default [
  {
    hosts: "fsicos2",
    vars: {
      nginxsite_name: "foo",
      lxd_vm_name: "foo",
    },
    tasks: [
      {
        name: tmpl`Remove nginx config for ${nginxsite_name}`,
        tags: "nginx",
        import_role: { name: "icos.nginxsite", tasks_from: "remove.yml" },
      },
      {
        name: tmpl`Remove lxd vm ${lxd_vm_name}`,
        tags: "lxd",
        import_role: { name: "icos.lxd_vm", tasks_from: "remove.yml" },
      },
    ],
  },
] satisfies Playbook;
