import { isDefined, raw, type TaskFile, truthy } from "../../../lib/ansible.ts";
import { rawTmpl, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${V.item} needs to be defined`,
    },
    when: raw("vars[item] is undefined"),
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
      state: tmpl`${rawTmpl("{% if nginxforward_enable %}")}link${
        rawTmpl("{% else %}")
      }absent${rawTmpl("{% endif %}")}`,
    },
    when: truthy(V.nginxforward_enable),
    notify: "reload nginx config",
  },
] satisfies TaskFile;
