import {
  nginxsite_path_available,
  nginxsite_path_confd,
  nginxsite_path_enable,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { tmpl } from "../../../lib/template.ts";
import { isUndefined, varByName } from "../../../lib/vars.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${item} needs to be defined` },
    when: isUndefined(varByName(item)),
    loop: [
      "nginxsite_name",
    ],
  },
  {
    name: "Remove config file",
    file: {
      dest: item,
      state: "absent",
    },
    loop: [
      nginxsite_path_enable,
      nginxsite_path_available,
      nginxsite_path_confd,
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
