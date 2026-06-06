import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { registry_domain } from "../../../lib/globals.ts";
import { jbuild_registry_pass, jbuild_users } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Generate keys for jbuild",
    openssh_keypair: {
      path: tmpl`/home/${item}/.ssh/jbuild`,
      owner: item,
      group: item,
    },
    loop: jbuild_users,
    register: "_jbuild_user_keys",
  },
  {
    name: "Generate jbuild ssh config",
    blockinfile: {
      path: tmpl`/home/${item}/.ssh/config`,
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
    loop: jbuild_users,
  },
  {
    name: "Create $HOME/bin directory",
    file: {
      path: tmpl`/home/${item}/bin`,
      state: "directory",
      owner: item,
      group: item,
    },
    loop: jbuild_users,
  },
  {
    name: "Create wrappers for edctl",
    copy: {
      dest: tmpl`/home/${item}/bin/edctl`,
      mode: "+x",
      content: `#!/bin/bash
ssh edctl /opt/edctl/edctl.py "$@"
`,
    },
    loop: jbuild_users,
  },
  {
    name: "Create wrappers for jyctl",
    copy: {
      dest: tmpl`/home/${item}/bin/jyctl`,
      mode: "+x",
      content: `#!/bin/bash
ssh jyctl /opt/jyctl/jyctl.py "$@"
`,
    },
    loop: jbuild_users,
  },
  {
    name: "Login to registry",
    become: true,
    become_user: item,
    "community.general.docker_login": {
      registry_url: registry_domain,
      username: "docker",
      password: jbuild_registry_pass,
    },
    loop: jbuild_users,
  },
] satisfies TaskFile;
