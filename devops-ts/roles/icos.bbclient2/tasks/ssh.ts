import {
  bbclient_ssh_bin,
  bbclient_ssh_config,
  bbclient_ssh_dir,
  bbclient_ssh_key,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { inventory_hostname } from "../../../lib/builtins.ts";
import { bbclient_name } from "../../../lib/sharedvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create ssh directory",
    file: {
      path: bbclient_ssh_dir,
      state: "directory",
      mode: 0o700,
    },
  },
  {
    name: "Generate RSA keys",
    args: { creates: bbclient_ssh_key },
    command:
      tmpl`ssh-keygen -q -t rsa -f ${bbclient_ssh_key} -N ""\n  -C "bbclient_${bbclient_name}@${inventory_hostname}"`,
  },
  {
    name: "Create ssh config",
    copy: {
      dest: bbclient_ssh_config,
      content: `UserKnownHostsFile {{ bbclient_ssh_hosts }}
Identityfile {{ bbclient_ssh_key }}

{% for bbclient_remote in bbclient_remotes %}
Host {{ bbclient_remote }}
    HostName {{ hostvars[bbclient_remote].bbserver_host }}
    User {{ hostvars[bbclient_remote].bbserver_user }}
    Port {{ hostvars[bbclient_remote].bbserver_port }}

{% endfor %}
`,
    },
  },
  {
    name: "Add ssh wrapper",
    copy: {
      mode: "+x",
      dest: bbclient_ssh_bin,
      content: `#!/usr/bin/bash
exec ssh -F {{ bbclient_ssh_config }} "$@"
`,
    },
  },
] satisfies TaskFile;
