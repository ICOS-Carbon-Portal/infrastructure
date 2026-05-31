import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Create filedrop user",
    user: {
      name: "filedrop",
      home: "/home/filedrop",
      shell: "/usr/sbin/nologin",
    },
    register: "_user",
  },
  {
    name: "Install Java",
    apt: { name: "default-jdk" },
  },
  {
    name: "Deploy filedrop jarfile as a service",
    include_role: { name: "icos.jarservice2" },
    vars: {
      jarservice_name: "filedrop",
      jarservice_home: expr("_user.home"),
      jarservice_local: expr("filedrop_jar_file"),
      jarservice_unit: expr("lookup('template', 'filedrop.service')"),
    },
    when: raw("filedrop_jar_file is defined"),
  },
  {
    name: "Create filedrop config file",
    copy: {
      dest: tmpl`${expr("_user.home")}/application.conf`,
      content: `cpfiledrop{
        folder = "{{ filedrop_data_home }}"
}
`,
    },
    notify: "restart filedrop",
  },
] satisfies TaskFile;
