-- Auto-generated from dovecot_logging.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , notify : Optional Text
    , lineinfile : Optional ({ path : Text, regex : Text, line : Text, state : Text })
    , loop : Optional (List ({ s : Text, f : Text }))
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , notify = None Text
    , lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text })
    , loop = None (List ({ s : Text, f : Text }))
  }
    }

in  [
    Task::{
      name = "Configure rsyslog to put dovecot in its own logfile",
      copy = Some {
        dest = "/etc/rsyslog.d/20-dovecot.conf"
      , content = ''
        :programname,isequal,"dovecot"          {{ dovecot_log_file }}
        & stop

      ''
    },
      notify = Some "Restart rsyslog"
    }
  , Task::{
      name = "Create logrotate config",
      copy = Some {
        dest = "/etc/logrotate.d/dovecot"
      , content = ''
        {{ dovecot_log_file }}
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
    }
    }
  , Task::{
      name = "Enable more logging",
      lineinfile = Some {
        path = "{{ item.f }}"
      , regex = "(?:^#\\s*{{ item.s }}\\s*=)|(?:^{{ item.s }} = yes)"
      , line = "{{ item.s }} = yes"
      , state = "present"
    },
      loop = Some [
        { s = "auth_verbose", f = "/etc/dovecot/conf.d/10-logging.conf" }
      , { s = "auth_debug", f = "/etc/dovecot/conf.d/10-logging.conf" }
      , { s = "mail_debug", f = "/etc/dovecot/conf.d/10-logging.conf" }
      , { s = "verbose_proctitle", f = "/etc/dovecot/dovecot.conf" }
    ]
    }
]
