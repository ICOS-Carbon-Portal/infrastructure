import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, rawTmpl, tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl`Run block as ${expr("_ssh_user")}`,
    become: true,
    become_user: expr("_ssh_user"),
    block: [
      {
        name: tmpl`Get home directory of ${expr("_ssh_user")}`,
        shell: tmpl`getent passwd ${expr("_ssh_user")} | cut -d: -f6`,
        register: "_home_dir",
        changed_when: false,
      },
      {
        name: "Make sure user .ssh directory is present",
        file: {
          path: tmpl`${expr("_home_dir.stdout")}/.ssh`,
          state: "directory",
          mode: 0o700,
        },
        register: "_ssh_dir",
      },
      {
        name: "Install the rsa private key",
        copy: {
          src: "roles/icos.flexpart/files/flexpart.rsa",
          dest: tmpl`${rawTmpl("{{ _ssh_dir.path}}")}/flexpart.rsa`,
          mode: 0o600,
        },
        register: "_rsa_file",
      },
      {
        name: "Add flexpart run host to each users known_hosts file",
        known_hosts: {
          path: tmpl`${expr("_ssh_dir.path")}/known_hosts`,
          name: expr("flexpart_ssh_remote_host"),
          key: tmpl`${expr("flexpart_ssh_remote_host")},${
            expr("flexpart_ssh_remote_ip")
          } ecdsa-sha2-nistp256 ${
            expr(
              "hostvars[flexpart_ssh_remote_host].ansible_ssh_host_key_ecdsa_public",
            )
          }`,
        },
      },
      {
        name: "Add flexpart users ssh config file",
        blockinfile: {
          create: true,
          path: tmpl`${expr("_ssh_dir.path")}/config`,
          mode: 0o600,
          marker: "# {mark} ansible config for flexpart",
          block: `Host flexpart
  User {{ flexpart_user }}
  HostName {{ flexpart_ssh_remote_ip }}
  IdentityFile {{ _ssh_dir.path }}/flexpart.rsa
`,
        },
      },
    ],
  },
] satisfies TaskFile;
