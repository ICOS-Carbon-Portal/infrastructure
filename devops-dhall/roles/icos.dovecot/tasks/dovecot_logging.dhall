-- Auto-generated from ../../../../devops/roles/icos.dovecot/tasks/dovecot_logging.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Configure rsyslog to put dovecot in its own logfile",
      copy = Some {
        dest = "/etc/rsyslog.d/20-dovecot.conf",
        mode = None Text,
        content = Some ''
        :programname,isequal,"dovecot"          {{ dovecot_log_file }}
        & stop

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "Restart rsyslog" ]
    }
  , Task::{
      name = Some "Create logrotate config",
      copy = Some {
        dest = "/etc/logrotate.d/dovecot",
        mode = None Text,
        content = Some ''
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
      name = Some "Enable more logging",
      lineinfile = Some {
        path = "{{ item.f }}",
        regex = Some "(?:^#\\s*{{ item.s }}\\s*=)|(?:^{{ item.s }} = yes)",
        line = Some "{{ item.s }} = yes",
        state = Some "present",
        backrefs = None Bool,
        regexp = None Text,
        create = None Bool,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = Some "auth_verbose",
            f = Some "/etc/dovecot/conf.d/10-logging.conf",
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = Some "auth_debug",
            f = Some "/etc/dovecot/conf.d/10-logging.conf",
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = Some "mail_debug",
            f = Some "/etc/dovecot/conf.d/10-logging.conf",
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = Some "verbose_proctitle",
            f = Some "/etc/dovecot/dovecot.conf",
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
      ])
    }
]
