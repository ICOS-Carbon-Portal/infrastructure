import {
  eq,
  hostvar,
  ne,
  not,
  register,
  type TaskFile,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const r = register("r");

export default [
  // LOCAL
  {
    name: "Read the public key",
    check_mode: false,
    slurpfact: {
      path: tmpl`${V.bbclient_ssh_key}.pub`,
      fact: "bbclient_key_data",
    },
  },

  // REMOTE
  {
    name: "Configure remote - bbserver - host",
    delegate_to: V.bbclient_remote,
    block: [
      {
        name: "Retrieve host keys",
        check_mode: false,
        shellfact: {
          // The keys don't always appear in the same order, so sort them.
          // Otherwise the known_hosts task on LOCAL will keep changing.
          exec: tmpl`ssh-keyscan -p ${
            hostvar(V.bbclient_remote).bbserver_port
          } localhost | sed "s/localhost/${
            hostvar(V.bbclient_remote).bbserver_host
          }/" | sort -u`,
          fact: "bbclient_remote_keys",
        },
      },
      {
        name: "Install public key",
        authorized_key: {
          user: V.bbclient_remote_user,
          state: "present",
          key: V.bbclient_key_data,
          key_options:
            tmpl`command="/usr/local/bin/borg serve --restrict-to-path ${V.bbclient_remote_repo}",restrict`,
        },
      },
    ],
  },

  // LOCAL
  {
    name: "Configure local - bbclient - host",
    become: true,
    become_user: V.bbclient_user,
    block: [
      {
        name: "Update known_hosts",
        blockinfile: {
          create: true,
          path: V.bbclient_ssh_hosts,
          marker: tmpl`# {mark} ${V.bbclient_remote}`,
          block: tmpl`${V.bbclient_remote_keys}
`,
        },
      },
      {
        name: "Initialize repo",
        command:
          tmpl`${V.bbclient_wrapper} init ${V.bbclient_repo_url} --encryption=none\n`,
        register: r,
        changed_when: [eq(r.rc, 0)],
        failed_when: [
          ne(r.rc, 0),
          not(r.stderr.startswith("A repository already exists at")),
        ],
      },
    ],
  },
] satisfies TaskFile;
