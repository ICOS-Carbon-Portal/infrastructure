-- Auto-generated from backup.yml

let Entry =
    { Type =
        { name : Text
    , include_role : Optional ({ name : Text, public : Bool })
    , vars : Optional ({ bbclient_user : Text, bbclient_name : Text, bbclient_home : Text, bbclient_timer_conf : Text, bbclient_timer_content : Text })
    , when : Text
    , template : Optional ({ dest : Text, src : Text, mode : Text })
  }
    , default =
        { include_role = None ({ name : Text, public : Bool })
    , vars = None ({ bbclient_user : Text, bbclient_name : Text, bbclient_home : Text, bbclient_timer_conf : Text, bbclient_timer_content : Text })
    , template = None ({ dest : Text, src : Text, mode : Text })
  }
    }

in  [
    Entry::{
      name = "Backup rdflog db",
      include_role = Some { name = "icos.bbclient2", public = True },
      vars = Some {
        bbclient_user = "root"
      , bbclient_name = "{{ rdflog_bbclient_name }}"
      , bbclient_home = "{{ rdflog_home }}/bbclient"
      , bbclient_timer_conf = "OnCalendar=00/6:11"
      , bbclient_timer_content = ''
        #!/bin/bash
        set -eu

        while read repo; do
            export BORG_REPO="$repo"
            docker exec rdflog pg_dump -U rdflog -Cc --if-exists -d rdflog | {{ bbclient_wrapper }} create '::{now}' -;
            {{ bbclient_wrapper }} prune --keep-within=7d --keep-daily=30 --keep-weekly=150
        done < "{{ bbclient_repo_file }}"

      ''
    },
      when = "rdflog_backup_enable | default(False)"
    }
  , Entry::{
      name = "Install rdflog restore scripts",
      when = "rdflog_backup_enable | default(False)",
      template = Some {
        dest = "/usr/local/bin/icos-rdflog-restore"
      , src = "icos-rdflog-restore.sh"
      , mode = "+x"
    }
    }
]
