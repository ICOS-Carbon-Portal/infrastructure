import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${V.item} needs to be defined` },
    when: raw("vars[item] is undefined"),
    loop: ["nginxauth_users", "nginxauth_name"],
  },
  {
    name: "Install apache2-utils",
    apt: { name: "apache2-utils" },
  },
  {
    name: "Install the passlib library",
    apt: { name: "python3-passlib" },
  },
  {
    name: "Create directory for auth file",
    file: {
      path: tmpl("{{ nginxauth_file | dirname }}"),
      state: "directory",
    },
  },
  {
    name: "Add basic auth users",
    htpasswd: {
      path: V.nginxauth_file,
      name: tmpl("{{ item.username }}"),
      password: tmpl("{{ item.password }}"),
    },
    loop: tmpl("{{ nginxauth_users }}"),
  },
] satisfies TaskFile;
