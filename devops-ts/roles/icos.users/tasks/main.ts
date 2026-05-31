import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Create user",
    user: {
      name: expr("item.name"),
      password: expr("item.password | default(omit)"),
      home: expr("item.home | default(omit)"),
      groups: expr("item.groups | default(omit)"),
      append: expr("item.groups | default(false) | bool"),
    },
    loop: expr("user_conf.create_users | default([])"),
  },
  {
    name: "Install public key",
    authorized_key: {
      user: expr("item.name"),
      key: expr("item.key"),
      state: "present",
      exclusive: true,
    },
    loop: expr("user_conf.create_users | default([])"),
  },
  {
    name: "Install password-less sudo rule",
    copy: {
      dest: tmpl`/etc/sudoers.d/${expr("item.name")}`,
      content: `{{ item.name }} ALL=(ALL) NOPASSWD: ALL
`,
    },
    when: raw("item.sudopwless | default(false)"),
    loop: expr("user_conf.create_users | default([])"),
  },
  {
    name: "Remove user",
    user: {
      name: expr("item.name"),
      remove: expr("item.remove | default(omit)"),
      state: "absent",
    },
    loop: expr("user_conf.remove_users | default([])"),
  },
] satisfies TaskFile;
