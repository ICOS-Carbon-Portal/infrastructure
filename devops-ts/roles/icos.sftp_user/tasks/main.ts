import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item, omit } from "../../../lib/builtins.ts";
import { sftp_user_dir, sftp_user_login } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { iff, tmpl } from "../../../lib/template.ts";
import {
  isTruthy,
  isUndefined,
  ne,
  not,
  or,
  truthy,
  varByName,
} from "../../../lib/vars.ts";
import { vault_pw_salt } from "../../../lib/vaultvars.ts";

const _parent = register("_parent");

export default [
  {
    fail: { msg: tmpl`${item} needs to be defined` },
    when: isUndefined(varByName(item)),
    loop: ["sftp_user_dir", "sftp_user_login"],
  },
  {
    name: "Check whether sftp parent directory exists",
    stat: { path: V._sftp_parent_dir },
    check_mode: false,
    register: _parent,
  },
  {
    name: "Create sftp parent directory",
    file: {
      path: V._sftp_parent_dir,
      state: "directory",
      owner: "root",
      group: "root",
    },
    when: not(_parent.stat.exists),
  },
  {
    name: "Create sftp user",
    user: {
      name: sftp_user_login,
      password: iff(
        V.sftp_user_password,
        V.sftp_user_password.passwordHash("sha512", vault_pw_salt),
        omit,
      ),
      create_home: isTruthy(V.sftp_user_pubkey).asValue(),
      shell: "/usr/sbin/nologin",
    },
    register: "_user",
  },
  {
    name: "Install public key",
    authorized_key: {
      user: sftp_user_login,
      key: V.sftp_user_pubkey,
    },
    when: truthy(V.sftp_user_pubkey),
  },
  {
    name: "Stat parent directory again",
    stat: { path: V._sftp_parent_dir },
    check_mode: false,
    register: _parent,
  },
  {
    name: "Fail if parent directory isn't owned by root",
    fail: { msg: tmpl`${V._sftp_parent_dir} must be owned by root` },
    when: or(ne(_parent.stat.uid, 0), ne(_parent.stat.gid, 0)),
  },
  {
    name: "Create sftp directory",
    file: {
      path: sftp_user_dir,
      state: "directory",
      owner: V.sftp_user_owner,
      group: V.sftp_user_group,
    },
  },
  {
    name: "Add sftp user config to sshd to sshd_config",
    blockinfile: {
      marker: tmpl`# {mark} ansible / sftp_user / ${sftp_user_login}`,
      create: true,
      insertafter: "EOF",
      path: "/etc/ssh/sshd_config",
      block: `Match User {{ sftp_user_login }}
  ChrootDirectory {{ _sftp_parent_dir }}
  ForceCommand internal-sftp -d {{ sftp_user_dir | basename }}
  DisableForwarding yes
  PasswordAuthentication yes
`,
    },
    notify: "reload sshd",
  },
  {
    name: "Print ssh config",
    debug: {
      msg: `# {{ sftp_user_password}}
Host {{ sftp_user_hostdesc }}
  HostName {{ ansible_host }}
  Port {{ ansible_port }}
  User {{ sftp_user_login }}
  {% if sftp_user_password %}
  PreferredAuthentications password
  {%- endif %}
`,
    },
  },
] satisfies TaskFile;
