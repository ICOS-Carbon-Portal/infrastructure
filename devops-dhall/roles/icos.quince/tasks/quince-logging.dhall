-- Auto-generated from quince-logging.yml

let Task =
    { Type =
        { name : Text
    , copy : { dest : Text, content : Text }
    , notify : Optional Text
  }
    , default =
        { notify = None Text
  }
    }

in  [
    Task::{
      name = "Create rsyslog config",
      copy = {
        dest = "/etc/rsyslog.d/30-quince.conf"
      , content = ''
        $FileCreateMode 0644
        :programname,isequal,"catalina.sh"          {{ quince_log_file }}
        & stop

      ''
    },
      notify = Some "restart rsyslog"
    }
  , Task::{
      name = "Create logrotate config",
      copy = {
        dest = "/etc/logrotate.d/quince"
      , content = ''
        {{ quince_log_file }}
        {
                rotate 12
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
]
