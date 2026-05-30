import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create user",
    user: {
      name: "{{ item.name }}",
      password: "{{ item.password | default(omit) }}",
      home: "{{ item.home | default(omit) }}",
      groups: "{{ item.groups | default(omit) }}",
      append: "{{ item.groups | default(false) | bool }}",
    },
    loop: "{{ user_conf.create_users | default([]) }}",
  },
  {
    name: "Install public key",
    authorized_key: {
      user: "{{ item.name }}",
      key: "{{ item.key }}",
      state: "present",
      exclusive: true,
    },
    loop: "{{ user_conf.create_users | default([]) }}",
  },
  {
    name: "Install password-less sudo rule",
    copy: {
      dest: "/etc/sudoers.d/{{ item.name }}",
      content: `{{ item.name }} ALL=(ALL) NOPASSWD: ALL
`,
    },
    when: raw("item.sudopwless | default(false)"),
    loop: "{{ user_conf.create_users | default([]) }}",
  },
  {
    name: "Remove user",
    user: {
      name: "{{ item.name }}",
      remove: "{{ item.remove | default(omit) }}",
      state: "absent",
    },
    loop: "{{ user_conf.remove_users | default([]) }}",
  },
] satisfies TaskFile;
