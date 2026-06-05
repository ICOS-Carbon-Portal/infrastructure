import { isUndefined, type TaskFile, varByName } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${V.item} needs to be defined` },
    when: isUndefined(varByName(V.item)),
    loop: [
      "nginxsite_name",
    ],
  },
  {
    name: "Remove config file",
    file: {
      dest: V.item,
      state: "absent",
    },
    loop: [
      V.nginxsite_path_enable,
      V.nginxsite_path_available,
      V.nginxsite_path_confd,
    ],
  },
  {
    name: "Reload nginx",
    systemd: {
      name: "nginx",
      state: "reloaded",
    },
    changed_when: false,
  },
] satisfies TaskFile;
