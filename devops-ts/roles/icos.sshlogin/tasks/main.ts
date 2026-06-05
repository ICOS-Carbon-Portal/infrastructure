import {
  and,
  group,
  isDefined,
  isUndefined,
  not,
  or,
  register,
  type TaskFile,
  varByName,
} from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

const _src_user = register("_src_user");

export default [
  {
    name: "Check that enough parameters are provided",
    fail: {
      msg:
        "Must set either sshlogin_user or both of sshlogin_src_user and sshlogin_dst_user",
    },
    when: not(
      group(
        or(
          isDefined(V.sshlogin_user),
          group(
            and(
              isDefined(V.sshlogin_src_user),
              isDefined(V.sshlogin_dst_user),
            ),
          ),
        ),
      ),
    ),
  },
  {
    name: "Use sshlogin_user to derive sshlogin_{src,dst}_user",
    when: isDefined(V.sshlogin_user),
    set_fact: {
      sshlogin_src_user: V.sshlogin_user,
      sshlogin_dst_user: V.sshlogin_user,
    },
  },
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${V.item} needs to be defined`,
    },
    when: isUndefined(varByName(V.item)),
    loop: [
      "sshlogin_dst",
      "sshlogin_src_user",
      "sshlogin_dst_user",
    ],
  },
  // SRC - Create user and directories
  {
    name: tmpl`Create ${V.sshlogin_src_user} user`,
    user: {
      name: V.sshlogin_src_user,
      home: V.sshlogin_src_home.default(V.omit),
      generate_ssh_key: true,
    },
    register: _src_user,
  },
  // DST - Retrieve IP and host keys
  {
    delegate_to: V.sshlogin_dst,
    name: "Retrieve destination host keys",
    shellfact: {
      exec: tmpl`ssh-keyscan localhost | sed "s/^localhost/${V.sshlogin_dst}/"`,
      fact: "sshlogin_dst_host_keys",
    },
  },
  // SRC - Add known_hosts and generate key
  {
    become: true,
    become_user: V.sshlogin_src_user,
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
          marker: tmpl`# {mark} ansible / sshlogin ${V.sshlogin_dst}`,
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
    delegate_to: V.sshlogin_dst,
    block: [
      {
        name: "Create destination user",
        user: {
          name: V.sshlogin_dst_user,
          home: V.sshlogin_dst_home.default(V.omit),
        },
        register: "_dst_user",
      },
      {
        name: "Install public key",
        authorized_key: {
          user: V.sshlogin_dst_user,
          state: "present",
          key: _src_user.ssh_public_key.ref,
          key_options: V.sshlogin_dst_key_options,
        },
      },
    ],
  },
] satisfies TaskFile;
