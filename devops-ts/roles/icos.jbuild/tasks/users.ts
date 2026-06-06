import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Generate keys for jbuild",
    openssh_keypair: {
      path: tmpl`/home/${V.item}/.ssh/jbuild`,
      owner: V.item,
      group: V.item,
    },
    loop: V.jbuild_users,
    register: "_jbuild_user_keys",
  },
  {
    name: "Generate jbuild ssh config",
    blockinfile: {
      path: tmpl`/home/${V.item}/.ssh/config`,
      marker: "# {mark} ansible / jbuild",
      create: true,
      insertafter: "EOF",
      block: `Host edctl
  Hostname {{ jbuild_edctl_host_name }}
  Port {{ jbuild_edctl_host_port }}
  User edctl
  IdentityFile ~/.ssh/jbuild

Host jyctl
  Hostname {{ jbuild_jyctl_host_name }}
  Port {{ jbuild_jyctl_host_port }}
  User jyctl
  IdentityFile ~/.ssh/jbuild

Host projectcommon
  Hostname {{ jbuild_rsync_host_name }}
  Port {{ jbuild_rsync_host_port }}
  User project
  IdentityFile ~/.ssh/jbuild
`,
    },
    loop: V.jbuild_users,
  },
  {
    name: "Create $HOME/bin directory",
    file: {
      path: tmpl`/home/${V.item}/bin`,
      state: "directory",
      owner: V.item,
      group: V.item,
    },
    loop: V.jbuild_users,
  },
  {
    name: "Create wrappers for edctl",
    copy: {
      dest: tmpl`/home/${V.item}/bin/edctl`,
      mode: "+x",
      content: `#!/bin/bash
ssh edctl /opt/edctl/edctl.py "$@"
`,
    },
    loop: V.jbuild_users,
  },
  {
    name: "Create wrappers for jyctl",
    copy: {
      dest: tmpl`/home/${V.item}/bin/jyctl`,
      mode: "+x",
      content: `#!/bin/bash
ssh jyctl /opt/jyctl/jyctl.py "$@"
`,
    },
    loop: V.jbuild_users,
  },
  {
    name: "Login to registry",
    become: true,
    become_user: V.item,
    "community.general.docker_login": {
      registry_url: V.registry_domain,
      username: "docker",
      password: V.jbuild_registry_pass,
    },
    loop: V.jbuild_users,
  },
] satisfies TaskFile;
