-- Auto-generated from dataold-on-host.yml

let Item =
    { Type =
        { import_role : Optional ({ name : Text })
    , name : Optional Text
    , copy : Optional ({ dest : Text, content : Text, mode : Optional Text })
    , register : Optional Text
    , when : Optional Text
    , systemd : Optional ({ name : Text, state : Text, `daemon-reload` : Optional Bool, enabled : Optional Bool })
    , loop : Optional (List Text)
    , template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool, validate : Optional Text })
    , iptables_raw : Optional ({ name : Text, rules : Text })
    , delegate_to : Optional Text
    , uri : Optional ({ url : Text })
    , failed_when : Optional (List Text)
    , retries : Optional Natural
    , delay : Optional Natural
  }
    , default =
        { import_role = None ({ name : Text })
    , name = None Text
    , copy = None ({ dest : Text, content : Text, mode : Optional Text })
    , register = None Text
    , when = None Text
    , systemd = None ({ name : Text, state : Text, `daemon-reload` : Optional Bool, enabled : Optional Bool })
    , loop = None (List Text)
    , template = None ({ src : Text, dest : Text, lstrip_blocks : Bool, validate : Optional Text })
    , iptables_raw = None ({ name : Text, rules : Text })
    , delegate_to = None Text
    , uri = None ({ url : Text })
    , failed_when = None (List Text)
    , retries = None Natural
    , delay = None Natural
  }
    }

in  [
    Item::{ import_role = Some { name = "icos.certbot2" } }
  , Item::{
      name = Some "Install rsyslog config for dataold",
      copy = Some {
        dest = "/etc/rsyslog.d/20-dataold.conf"
      , content = ''
        # The tag ends with ":" once it's in rsyslogd.
        if $syslogtag == "dataold:" then {
           action(type="omfile" file="{{ dataold_log_file }}")
           stop
        }

      ''
      , mode = None Text
    },
      register = Some "_rsyslog"
    }
  , Item::{
      name = Some "Restart {{ item }}",
      when = Some "_rsyslog.changed",
      systemd = Some {
        name = "{{ item }}"
      , state = "restarted"
      , `daemon-reload` = None Bool
      , enabled = None Bool
    },
      loop = Some [ "rsyslog", "syslog.socket" ]
    }
  , Item::{
      name = Some "Create logrotate config for dataold",
      copy = Some {
        dest = "/etc/logrotate.d/dataold"
      , content = ''
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

      ''
      , mode = None Text
    }
    }
  , Item::{
      name = Some "Copy dataold.conf",
      register = Some "_cf",
      template = Some {
        src = "dataold.conf"
      , dest = "/etc/nginx/"
      , lstrip_blocks = True
      , validate = Some "nginx -t -c %s"
    }
    }
  , Item::{
      name = Some "Copy dataold.service",
      register = Some "_sr",
      template = Some {
        src = "dataold.service"
      , dest = "/etc/systemd/system/"
      , lstrip_blocks = True
      , validate = None Text
    }
    }
  , Item::{
      name = Some "Start dataold service",
      systemd = Some {
        name = "dataold.service"
      , state = "{{ 'restarted' if _cf.changed or _sr.changed else 'started' }}"
      , `daemon-reload` = Some True
      , enabled = Some True
    }
    }
  , Item::{
      name = Some "Add a certbot renewal hook",
      copy = Some {
        dest = "/etc/letsencrypt/renewal-hooks/deploy/dataold.sh"
      , content = ''
        #!/bin/bash
        systemctl reload dataold

      ''
      , mode = Some "+x"
    }
    }
  , Item::{
      name = Some "Open firewall for port {{ dataold_ext_port }}",
      iptables_raw = Some {
        name = "allow_{{ dataold_ext_port }}"
      , rules = "-A INPUT -p tcp --dport {{ dataold_ext_port }} -j ACCEPT -m comment --comment 'dataold'"
    }
    }
  , Item::{
      name = Some "Test access to dataold from localhost",
      register = Some "_r",
      delegate_to = Some "localhost",
      uri = Some { url = "https://{{ certbot_domains | first }}:{{ dataold_ext_port }}" },
      failed_when = Some [ "\"TLSV1_ALERT_PROTOCOL_VERSION\" not in _r.msg" ],
      retries = Some 10,
      delay = Some 3
    }
]
