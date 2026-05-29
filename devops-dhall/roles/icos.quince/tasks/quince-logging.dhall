-- Auto-generated from quince-logging.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create rsyslog config",
      copy = Some {
        src = None Text
      , dest = "/etc/rsyslog.d/30-quince.conf"
      , mode = None Text
      , content = Some ''
        $FileCreateMode 0644
        :programname,isequal,"catalina.sh"          {{ quince_log_file }}
        & stop

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "restart rsyslog" ]
    }
  , Task::{
      name = Some "Create logrotate config",
      copy = Some {
        src = None Text
      , dest = "/etc/logrotate.d/quince"
      , mode = None Text
      , content = Some ''
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
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
