import { register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

const _rsyslog = register("_rsyslog");

export default [
  {
    import_role: { name: "icos.certbot2" },
  },
  {
    name: "Install rsyslog config for dataold",
    copy: {
      dest: "/etc/rsyslog.d/20-dataold.conf",
      content: `# The tag ends with ":" once it's in rsyslogd.
if $syslogtag == "dataold:" then {
   action(type="omfile" file="{{ dataold_log_file }}")
   stop
}
`,
    },
    register: _rsyslog,
  },
  {
    name: tmpl`Restart ${V.item}`,
    when: _rsyslog.changed,
    systemd: {
      name: V.item,
      state: "restarted",
    },
    loop: [
      "rsyslog",
      // 2022-02-10 This shouldn't (and wasn't) needed. But now there's some kind
      // of strange interaction between systemd-journald, syslog.socket and
      // rsyslog.service.
      "syslog.socket",
    ],
  },
  {
    name: "Create logrotate config for dataold",
    copy: {
      dest: "/etc/logrotate.d/dataold",
      content: `{{ dataold_log_file }}
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
  {
    name: "Copy dataold.conf",
    template: {
      src: "dataold.conf",
      dest: "/etc/nginx/",
      lstrip_blocks: true,
      validate: "nginx -t -c %s",
    },
    register: "_cf",
  },
  {
    name: "Copy dataold.service",
    template: {
      src: "dataold.service",
      dest: "/etc/systemd/system/",
      lstrip_blocks: true,
    },
    register: "_sr",
  },
  {
    name: "Start dataold service",
    systemd: {
      "daemon-reload": true,
      enabled: true,
      state: expr("'restarted' if _cf.changed or _sr.changed else 'started'"),
      name: "dataold.service",
    },
  },
  {
    name: "Add a certbot renewal hook",
    copy: {
      dest: "/etc/letsencrypt/renewal-hooks/deploy/dataold.sh",
      mode: "+x",
      content: `#!/bin/bash
systemctl reload dataold
`,
    },
  },
  {
    name: tmpl`Open firewall for port ${V.dataold_ext_port}`,
    iptables_raw: {
      name: tmpl`allow_${V.dataold_ext_port}`,
      rules:
        tmpl`-A INPUT -p tcp --dport ${V.dataold_ext_port} -j ACCEPT -m comment --comment 'dataold'`,
    },
  },
  {
    name: "Test access to dataold from localhost",
    delegate_to: "localhost",
    uri: {
      url: tmpl`https://${
        expr("certbot_domains | first")
      }:${V.dataold_ext_port}`,
    },
    register: "_r",
    failed_when: [
      // The purpose of dataold is no re-enable TLS1.0 - an old and insecure
      // version of TLS, hence we _want_ this url to fail with a particular error.
      '"TLSV1_ALERT_PROTOCOL_VERSION" not in _r.msg',
    ],
    retries: 10,
    delay: 3,
  },
] satisfies TaskFile;
