import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import {
  nginxforward_name,
  nginxforward_users,
} from "../../../lib/paramvars.ts";
import { iff, tmpl } from "../../../lib/template.ts";
import {
  isDefined,
  isUndefined,
  truthy,
  varByName,
} from "../../../lib/vars.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${item} needs to be defined`,
    },
    when: isUndefined(varByName(item)),
    loop: [
      "nginxforward_port",
      "nginxforward_name",
      "nginxforward_cert",
      "nginxforward_domains",
    ],
  },
  {
    import_tasks: "auth.yml",
    when: isDefined(nginxforward_users),
    tags: "nginxforward_auth",
  },
  {
    name: tmpl`Copy config for ${nginxforward_name}`,
    template: {
      src: V.nginxforward_file,
      dest: V.nginxforward_path_available,
    },
    notify: "reload nginx config",
  },
  {
    name: "Create symlink to sites-enabled",
    file: {
      dest: V.nginxforward_path_enabled,
      src: V.nginxforward_path_available,
      state: iff(V.nginxforward_enable, "link", "absent"),
    },
    when: truthy(V.nginxforward_enable),
    notify: "reload nginx config",
  },
] satisfies TaskFile;
