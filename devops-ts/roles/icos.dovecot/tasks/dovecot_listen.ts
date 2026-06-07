import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Change listening port",
    lineinfile: {
      path: "/etc/dovecot/conf.d/10-master.conf",
      regex: tmpl`(?:#port = 993$)|(?:^    port = ${V.dovecot_port}$)`,
      line: tmpl`    port = ${V.dovecot_port}`,
      state: "present",
    },
  },
  {
    name: "Allow dovecot through firewall",
    iptables_raw: {
      name: "allow_dovecot",
      rules:
        tmpl`-A INPUT -p tcp --dport ${V.dovecot_port} -j ACCEPT -m comment --comment 'dovecot'`,
    },
  },
  {
    name: "Add postfix lmtp listener",
    blockinfile: {
      path: "/etc/dovecot/conf.d/10-master.conf",
      marker: "# {mark} ansible / icos.dovecot / postfix lmtp",
      insertafter: "^service lmtp {",
      block: `  unix_listener {{ dovecot_lmtp }} {
    user = postfix
    group = postfix
  }
`,
    },
  },
] satisfies TaskFile;
