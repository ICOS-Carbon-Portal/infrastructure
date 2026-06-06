import {
  dovecot_auth_file,
  dovecot_vmail_home,
  dovecot_vmail_name,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create dovecot vmail user",
    user: {
      name: dovecot_vmail_name,
      home: dovecot_vmail_home,
      create_home: true,
      shell: "/usr/sbin/nologin",
    },
    register: "dovecot_vmail_user",
  },
  {
    name: tmpl`Copy ${dovecot_auth_file}`,
    template: {
      src: dovecot_auth_file,
      dest: "/etc/dovecot/conf.d",
    },
  },
  {
    name: "Add passwd-file authentication to dovecot",
    lineinfile: {
      path: "/etc/dovecot/conf.d/10-auth.conf",
      line: tmpl`!include ${dovecot_auth_file.basename()}`,
      state: "present",
    },
  },
] satisfies TaskFile;
