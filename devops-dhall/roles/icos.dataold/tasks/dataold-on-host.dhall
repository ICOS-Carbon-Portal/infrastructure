-- Auto-generated from ../../../../devops/roles/icos.dataold/tasks/dataold-on-host.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_role = Some (Task.Poly_import_role.Record { name = "icos.certbot2", tasks_from = None Text })
    }
  , Task::{
      name = Some "Install rsyslog config for dataold",
      copy = Some {
        dest = "/etc/rsyslog.d/20-dataold.conf",
        mode = None Text,
        content = Some ''
        # The tag ends with ":" once it's in rsyslogd.
        if $syslogtag == "dataold:" then {
           action(type="omfile" file="{{ dataold_log_file }}")
           stop
        }

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_rsyslog"
    }
  , Task::{
      name = Some "Restart {{ item }}",
      when = Some [ "_rsyslog.changed" ],
      systemd = Some {
        name = Some "{{ item }}",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "rsyslog", "syslog.socket" ])
    }
  , Task::{
      name = Some "Create logrotate config for dataold",
      copy = Some {
        dest = "/etc/logrotate.d/dataold",
        mode = None Text,
        content = Some ''
        {{ dataold_log_file }}
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

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Copy dataold.conf",
      template = Some {
        src = "dataold.conf",
        dest = "/etc/nginx/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = Some "nginx -t -c %s",
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_cf"
    }
  , Task::{
      name = Some "Copy dataold.service",
      template = Some {
        src = "dataold.service",
        dest = "/etc/systemd/system/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_sr"
    }
  , Task::{
      name = Some "Start dataold service",
      systemd = Some {
        name = Some "dataold.service",
        state = Some "{{ 'restarted' if _cf.changed or _sr.changed else 'started' }}",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = Some "True",
        status = None Text
    }
    }
  , Task::{
      name = Some "Add a certbot renewal hook",
      copy = Some {
        dest = "/etc/letsencrypt/renewal-hooks/deploy/dataold.sh",
        mode = Some "+x",
        content = Some ''
        #!/bin/bash
        systemctl reload dataold

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Open firewall for port {{ dataold_ext_port }}",
      iptables_raw = Some {
        name = "allow_{{ dataold_ext_port }}",
        rules = Some "-A INPUT -p tcp --dport {{ dataold_ext_port }} -j ACCEPT -m comment --comment 'dataold'",
        table = None Text,
        state = None Text,
        weight = None Natural
    }
    }
  , Task::{
      name = Some "Test access to dataold from localhost",
      delegate_to = Some "localhost",
      uri = Some {
        url = "https://{{ certbot_domains | first }}:{{ dataold_ext_port }}",
        return_content = None Bool,
        method = None Text,
        user = None Text,
        password = None Text
    },
      register = Some "_r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "\"TLSV1_ALERT_PROTOCOL_VERSION\" not in _r.msg" ]),
      retries = Some 10,
      delay = Some 3
    }
]
