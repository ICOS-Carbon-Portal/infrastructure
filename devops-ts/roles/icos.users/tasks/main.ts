import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Create user",
    user: {
      name: tmpl("{{ item.name }}"),
      password: tmpl("{{ item.password | default(omit) }}"),
      home: tmpl("{{ item.home | default(omit) }}"),
      groups: tmpl("{{ item.groups | default(omit) }}"),
      append: tmpl("{{ item.groups | default(false) | bool }}"),
    },
    loop: tmpl("{{ user_conf.create_users | default([]) }}"),
  },
  {
    name: "Install public key",
    authorized_key: {
      user: tmpl("{{ item.name }}"),
      key: tmpl("{{ item.key }}"),
      state: "present",
      exclusive: true,
    },
    loop: tmpl("{{ user_conf.create_users | default([]) }}"),
  },
  {
    name: "Install password-less sudo rule",
    copy: {
      dest: tmpl("/etc/sudoers.d/{{ item.name }}"),
      content: `{{ item.name }} ALL=(ALL) NOPASSWD: ALL
`,
    },
    when: raw("item.sudopwless | default(false)"),
    loop: tmpl("{{ user_conf.create_users | default([]) }}"),
  },
  {
    name: "Remove user",
    user: {
      name: tmpl("{{ item.name }}"),
      remove: tmpl("{{ item.remove | default(omit) }}"),
      state: "absent",
    },
    loop: tmpl("{{ user_conf.remove_users | default([]) }}"),
  },
] satisfies TaskFile;
