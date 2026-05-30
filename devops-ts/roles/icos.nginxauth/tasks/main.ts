import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: "{{ item }} needs to be defined" },
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
      path: "{{ nginxauth_file | dirname }}",
      state: "directory",
    },
  },
  {
    name: "Add basic auth users",
    htpasswd: {
      path: "{{ nginxauth_file }}",
      name: "{{ item.username }}",
      password: "{{ item.password }}",
    },
    loop: "{{ nginxauth_users }}",
  },
] satisfies TaskFile;
