import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create dovecot vmail user",
    user: {
      name: V.dovecot_vmail_name,
      home: V.dovecot_vmail_home,
      create_home: true,
      shell: "/usr/sbin/nologin",
    },
    register: "dovecot_vmail_user",
  },
  {
    name: tmpl`Copy ${V.dovecot_auth_file}`,
    template: {
      src: V.dovecot_auth_file,
      dest: "/etc/dovecot/conf.d",
    },
  },
  {
    name: "Add passwd-file authentication to dovecot",
    lineinfile: {
      path: "/etc/dovecot/conf.d/10-auth.conf",
      line: tmpl`!include ${V.dovecot_auth_file.basename()}`,
      state: "present",
    },
  },
] satisfies TaskFile;
