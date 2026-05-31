import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install postfix",
    apt: {
      name: "postfix",
      state: "present",
    },
  },
  {
    name: "Start and enable postfix",
    service: {
      name: "postfix",
      state: "started",
      enabled: true,
    },
  },
  {
    name: "Set configuration parameters",
    postconf: {
      param: expr("item.param"),
      value: expr("item.value"),
      append: expr("item.append | default(omit)"),
      reload: expr("item.reload | default(omit)"),
      separator: expr("item.separator | default(omit)"),
    },
    loop: V.postfix_config_list,
  },
  {
    name: "Allow SMTP through firewall",
    iptables_raw: {
      name: "allow_SMTP",
      rules: "-A INPUT -p tcp --dport 25 -j ACCEPT -m comment --comment 'smtp'",
    },
  },
  {
    name: "Install fail2ban",
    tags: "postfix_fail2ban",
    include_role: {
      name: "icos.fail2ban",
      apply: { tags: "postfix_fail2ban" },
    },
    vars: {
      fail2ban_config_files: [
        {
          dest: "/etc/fail2ban/jail.d/postfix.local",
          content: `[postfix]
enabled = true
mode = aggressive
`,
        },
        {
          dest: "/etc/fail2ban/filter.d/postfix-auth.local",
          content: `[Definition]
# Stop stupid bots from filling logs.
failregex = lost connection after AUTH from unknown\\[<HOST>\\]$
`,
        },
        {
          dest: "/etc/fail2ban/jail.d/postfix-auth.local",
          content: `[postfix-auth]
enabled = true
port    = smtp
filter  = postfix-auth
logpath = /var/log/mail.log
maxretry = 1
bantime  = 1h
`,
        },
      ],
    },
  },
] satisfies TaskFile;
