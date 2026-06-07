import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item, omit } from "../../../lib/builtins.ts";
import {
  sshlogin_dst,
  sshlogin_dst_home,
  sshlogin_dst_host_keys,
  sshlogin_dst_user,
  sshlogin_src_home,
  sshlogin_src_user,
  sshlogin_user,
} from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import {
  and,
  group,
  isDefined,
  isUndefined,
  not,
  or,
  varByName,
} from "../../../lib/vars.ts";

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
          isDefined(sshlogin_user),
          group(
            and(
              isDefined(sshlogin_src_user),
              isDefined(sshlogin_dst_user),
            ),
          ),
        ),
      ),
    ),
  },
  {
    name: "Use sshlogin_user to derive sshlogin_{src,dst}_user",
    when: isDefined(sshlogin_user),
    set_fact: {
      sshlogin_src_user: sshlogin_user,
      sshlogin_dst_user: sshlogin_user,
    },
  },
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${item} needs to be defined`,
    },
    when: isUndefined(varByName(item)),
    loop: [
      "sshlogin_dst",
      "sshlogin_src_user",
      "sshlogin_dst_user",
    ],
  },
  // SRC - Create user and directories
  {
    name: tmpl`Create ${sshlogin_src_user} user`,
    user: {
      name: sshlogin_src_user,
      home: sshlogin_src_home.default(omit),
      generate_ssh_key: true,
    },
    register: _src_user,
  },
  // DST - Retrieve IP and host keys
  {
    delegate_to: sshlogin_dst,
    name: "Retrieve destination host keys",
    shellfact: {
      exec: tmpl`ssh-keyscan localhost | sed "s/^localhost/${sshlogin_dst}/"`,
      fact: "sshlogin_dst_host_keys",
    },
  },
  // SRC - Add known_hosts and generate key
  {
    become: true,
    become_user: sshlogin_src_user,
    block: [
      {
        name: "Update known_hosts",
        known_hosts: {
          path: V.sshlogin_src_known_hosts,
          name: V.sshlogin_src_dst,
          key: item,
        },
        loop: sshlogin_dst_host_keys.strip().split("\\n"),
      },
      {
        name: "Add ssh config",
        blockinfile: {
          marker: tmpl`# {mark} ansible / sshlogin ${sshlogin_dst}`,
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
    delegate_to: sshlogin_dst,
    block: [
      {
        name: "Create destination user",
        user: {
          name: sshlogin_dst_user,
          home: sshlogin_dst_home.default(omit),
        },
        register: "_dst_user",
      },
      {
        name: "Install public key",
        authorized_key: {
          user: sshlogin_dst_user,
          state: "present",
          key: _src_user.ssh_public_key.ref,
          key_options: V.sshlogin_dst_key_options,
        },
      },
    ],
  },
] satisfies TaskFile;
