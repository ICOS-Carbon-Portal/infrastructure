import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

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
    when: raw("nginxforward_users is defined"),
    tags: "nginxforward_auth",
  },
  {
    name: tmpl("Copy config for {{ nginxforward_name }}"),
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
      state: tmpl(
        "{% if nginxforward_enable %}link{% else %}absent{% endif %}",
      ),
    },
    when: raw("nginxforward_enable"),
    notify: "reload nginx config",
  },
] satisfies TaskFile;
