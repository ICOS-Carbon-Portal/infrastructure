import {
  iff,
  isDefined,
  isUndefined,
  type TaskFile,
  truthy,
  varByName,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${V.item} needs to be defined`,
    },
    when: isUndefined(varByName(V.item)),
    loop: [
      "nginxforward_port",
      "nginxforward_name",
      "nginxforward_cert",
      "nginxforward_domains",
    ],
  },
  {
    import_tasks: "auth.yml",
    when: isDefined(V.nginxforward_users),
    tags: "nginxforward_auth",
  },
  {
    name: tmpl`Copy config for ${V.nginxforward_name}`,
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
