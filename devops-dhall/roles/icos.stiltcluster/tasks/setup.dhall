-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, state : Text, shell : Text, groups : Text, append : Text })
    , apt : Optional ({ name : Text })
    , file : Optional ({ path : Text, state : Text })
    , tags : Optional Text
    , include_role : Optional ({ name : Text, apply : { tags : Text } })
    , vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
    , cron : Optional ({ name : Text, state : Text })
    , register : Optional Text
    , failed_when : Optional (List Text)
  }
    , default =
        { user = None ({ name : Text, home : Text, state : Text, shell : Text, groups : Text, append : Text })
    , apt = None ({ name : Text })
    , file = None ({ path : Text, state : Text })
    , tags = None Text
    , include_role = None ({ name : Text, apply : { tags : Text } })
    , vars = None ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
    , cron = None ({ name : Text, state : Text })
    , register = None Text
    , failed_when = None (List Text)
  }
    }

in  [
    Task::{
      name = "Create stiltcluster user",
      user = Some {
        name = "{{ stiltcluster_username }}"
      , home = "{{ stiltcluster_home }}"
      , state = "present"
      , shell = "/bin/bash"
      , groups = "{{ \"docker\" if stiltcluster_docker else omit }}"
      , append = "{{ \"yes\" if stiltcluster_docker else omit }}"
    }
    }
  , Task::{ name = "Install jre", apt = Some { name = "default-jre-headless" } }
  , Task::{
      name = "Create bin directory",
      file = Some { path = "{{ stiltcluster_bindir }}", state = "directory" }
    }
  , Task::{
      name = "Install remove-old-stiltruns timer",
      tags = Some "stiltcluster_timer",
      include_role = Some { name = "icos.timer", apply = { tags = "stiltcluster_timer" } },
      vars = Some {
        timer_user = "stiltcluster"
      , timer_home = "/opt/remove-old-stiltruns"
      , timer_name = "remove-old-stiltruns"
      , timer_conf = "OnCalendar=daily"
      , timer_content = ''
        #!/bin/bash
        # Remove old directories from $HOME/.stiltrun
        #
        # These are created automatically by stilt.py when running stilt simulations. In
        # the normal case they're then removed by the stiltweb backend. This script -
        # run from cron - is an extra safety to keep $HOME to slowly fill up.

        set -u
        set -e

        cd "$HOME/.stiltruns"

        # maxdepth keep it from recursing into directories it's just deleted
        # -mtime is the number of days old the directories may be
        find . -maxdepth 1 -name 'stilt-run-*' -type d -mtime "+10" -exec rm -rf -- '{}' \;

      ''
    }
    }
  , Task::{
      name = "Remove the remove-old-stiltruns cron job",
      cron = Some { name = "remove old stiltruns", state = "absent" },
      register = Some "_r",
      failed_when = Some [ "_r.failed", "_r.msg.find('required executable \"crontab\"') < 0" ]
    }
]
