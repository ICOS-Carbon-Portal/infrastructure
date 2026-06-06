import { type TaskFile } from "../../../lib/ansible/play.ts";
import { filedrop_jar_file } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { lookup, tmpl } from "../../../lib/template.ts";
import { isDefined } from "../../../lib/vars.ts";

const _user = register("_user");

export default [
  {
    name: "Create filedrop user",
    user: {
      name: "filedrop",
      home: "/home/filedrop",
      shell: "/usr/sbin/nologin",
    },
    register: _user,
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
      jarservice_home: _user.home.ref,
      jarservice_local: filedrop_jar_file,
      jarservice_unit: lookup("template", "filedrop.service"),
    },
    when: isDefined(filedrop_jar_file),
  },
  {
    name: "Create filedrop config file",
    copy: {
      dest: tmpl`${_user.home.ref}/application.conf`,
      content: `cpfiledrop{
        folder = "{{ filedrop_data_home }}"
}
`,
    },
    notify: "restart filedrop",
  },
] satisfies TaskFile;
