import { loopOver, type TaskFile, type Tmpl } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Configure rsyslog to put dovecot in its own logfile",
    copy: {
      dest: "/etc/rsyslog.d/20-dovecot.conf",
      content: `:programname,isequal,"dovecot"          {{ dovecot_log_file }}
& stop
`,
    },
    notify: "Restart rsyslog",
  },
  {
    name: "Create logrotate config",
    copy: {
      dest: "/etc/logrotate.d/dovecot",
      content: `{{ dovecot_log_file }}
{
        rotate 6
        monthly
        missingok
        notifempty
        compress
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
}
`,
    },
  },
  loopOver<{ f: Tmpl; s: Tmpl }>(
    [
      { s: "auth_verbose", f: "/etc/dovecot/conf.d/10-logging.conf" },
      { s: "auth_debug", f: "/etc/dovecot/conf.d/10-logging.conf" },
      { s: "mail_debug", f: "/etc/dovecot/conf.d/10-logging.conf" },
      { s: "verbose_proctitle", f: "/etc/dovecot/dovecot.conf" },
    ],
    (item) => ({
      name: "Enable more logging",
      lineinfile: {
        path: item.f,
        // Only change commented-out lines, thus replacing the defaults.
        regex: tmpl("(?:^#\\s*{{ item.s }}\\s*=)|(?:^{{ item.s }} = yes)"),
        line: tmpl("{{ item.s }} = yes"),
        state: "present",
      },
    }),
  ),
] satisfies TaskFile;
