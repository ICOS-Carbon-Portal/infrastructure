-- Auto-generated from monitor.yml

let Entry =
    { Type =
        { name : Text
    , cron : Optional ({ user : Text, state : Text, name : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text, timer_content : Text })
  }
    , default =
        { cron = None ({ user : Text, state : Text, name : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text, timer_content : Text })
  }
    }

in  [
    Entry::{
      name = "Remove cron job",
      cron = Some { user = "{{ bbserver_user }}", state = "absent", name = "bbserver_borgmon" }
    }
  , Entry::{
      name = "Create borgmon timer",
      include_role = Some { name = "icos.timer" },
      vars = Some {
        timer_user = "bbserver"
      , timer_home = "{{ bbserver_monitor_home }}"
      , timer_name = "bbserver-borgmon"
      , timer_conf = "OnCalendar=*:0/5"
      , timer_envs = [
          "PYTHONUNBUFFERED=1"
        , "BORG_RELOCATED_REPO_ACCESS_IS_OK=yes"
        , "BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes"
        , "PATH=/usr/bin:/usr/local/bin"
      ]
      , timer_content = "{{ lookup('template', 'borgmon.py') }}"
    }
    }
]
