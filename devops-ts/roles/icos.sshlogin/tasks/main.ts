import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that enough parameters are provided",
    fail: {
      msg:
        "Must set either sshlogin_user or both of sshlogin_src_user and sshlogin_dst_user",
    },
    when: raw(
      "not (sshlogin_user is defined or\n    (sshlogin_src_user is defined and sshlogin_dst_user is defined))",
    ),
  },
  {
    name: "Use sshlogin_user to derive sshlogin_{src,dst}_user",
    when: raw("sshlogin_user is defined"),
    set_fact: {
      sshlogin_src_user: expr("sshlogin_user"),
      sshlogin_dst_user: expr("sshlogin_user"),
    },
  },
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${V.item} needs to be defined`,
    },
    when: raw("vars[item] is undefined"),
    loop: [
      "sshlogin_dst",
      "sshlogin_src_user",
      "sshlogin_dst_user",
    ],
  },
  // SRC - Create user and directories
  {
    name: tmpl`Create ${expr("sshlogin_src_user")} user`,
    user: {
      name: expr("sshlogin_src_user"),
      home: expr("sshlogin_src_home | default(omit)"),
      generate_ssh_key: true,
    },
    register: "_src_user",
  },
  // DST - Retrieve IP and host keys
  {
    delegate_to: expr("sshlogin_dst"),
    name: "Retrieve destination host keys",
    shellfact: {
      exec: tmpl`ssh-keyscan localhost | sed "s/^localhost/${
        expr("sshlogin_dst")
      }/"`,
      fact: "sshlogin_dst_host_keys",
    },
  },
  // SRC - Add known_hosts and generate key
  {
    become: true,
    become_user: expr("sshlogin_src_user"),
    block: [
      {
        name: "Update known_hosts",
        known_hosts: {
          path: V.sshlogin_src_known_hosts,
          name: V.sshlogin_src_dst,
          key: V.item,
        },
        loop: expr("sshlogin_dst_host_keys.strip().split('\\n')"),
      },
      {
        name: "Add ssh config",
        blockinfile: {
          marker: tmpl`# {mark} ansible / sshlogin ${expr("sshlogin_dst")}`,
          create: true,
          path: V.sshlogin_src_ssh_config,
          block: `Host {{ sshlogin_src_dst_name }}
  Hostname {{ sshlogin_src_dst_host }}
  Port {{ sshlogin_src_dst_port }}
  User {{ sshlogin_dst_user }}
`,
        },
      },
    ],
  },
  // DST - Add key
  {
    delegate_to: expr("sshlogin_dst"),
    block: [
      {
        name: "Create destination user",
        user: {
          name: expr("sshlogin_dst_user"),
          home: expr("sshlogin_dst_home | default(omit)"),
        },
        register: "_dst_user",
      },
      {
        name: "Install public key",
        authorized_key: {
          user: expr("sshlogin_dst_user"),
          state: "present",
          key: expr("_src_user.ssh_public_key"),
          key_options: V.sshlogin_dst_key_options,
        },
      },
    ],
  },
] satisfies TaskFile;
