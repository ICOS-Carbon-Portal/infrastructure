-- Auto-generated from backup.yml

let Item =
    { Type =
        { name : Optional Text
    , cron : Optional ({ state : Text, name : Text })
    , file : Optional ({ path : Text, state : Text })
    , include_role : Optional ({ name : Text, public : Bool })
    , vars : Optional ({ bbclient_name : Text, bbclient_home : Text, bbclient_timer_conf : Text, bbclient_timer_content : Text })
  }
    , default =
        { name = None Text
    , cron = None ({ state : Text, name : Text })
    , file = None ({ path : Text, state : Text })
    , include_role = None ({ name : Text, public : Bool })
    , vars = None ({ bbclient_name : Text, bbclient_home : Text, bbclient_timer_conf : Text, bbclient_timer_content : Text })
  }
    }

in  [
    Item::{
      name = Some "Remove backup from crontab",
      cron = Some { state = "absent", name = "cpmeta_backup" }
    }
  , Item::{
      name = Some "Remove old backup script",
      file = Some { path = "{{ cpmeta_home }}/backup.sh", state = "absent" }
    }
  , Item::{
      include_role = Some { name = "icos.bbclient2", public = True },
      vars = Some {
        bbclient_name = "{{ cpmeta_bbclient_name }}"
      , bbclient_home = "{{ cpmeta_home }}/.bbclient"
      , bbclient_timer_conf = ''
        OnCalendar=hourly
        RandomizedDelaySec=10m

      ''
      , bbclient_timer_content = ''
        #!/bin/bash
        set -xEeo pipefail
        cd "{{ cpmeta_home }}"

        export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

        {{ bbclient_all }} create -xvs "::{now}" "{{ cpmeta_filestorage_target }}" submitters.conf
        {{ bbclient_all }} prune -vs --keep-within 7d --keep-daily=30 --keep-weekly=50
        {{ bbclient_all }} compact --verbose

      ''
    }
    }
]
