-- Auto-generated from ../devops/static.yml

[
    {
      hosts = "fsicos2"
    , vars = {
        bbclient_home = "/opt/bbclient-nginx-static"
      , backup_script = "{{ bbclient_home }}/backup.sh"
    }
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , vars : Optional ({ nginxsite_name : Text, nginxsite_file : Text })
        , bbclient_name : Optional Text
        , bbclient_timer_content : Optional Text
      }
        , default =
            { vars = None ({ nginxsite_name : Text, nginxsite_file : Text })
        , bbclient_name = None Text
        , bbclient_timer_content = None Text
      }
        }

    in  [
        Role::{
          role = "icos.nginxsite",
          tags = "static",
          vars = Some { nginxsite_name = "static", nginxsite_file = "files/domains/static.conf" }
        }
      , Role::{
          role = "icos.bbclient2",
          tags = "bbclient",
          bbclient_name = Some "nginx-static",
          bbclient_timer_content = Some ''
          #!/bin/bash
          set -eu
          export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

          echo "Creating"
          {{ bbclient_all}} create --stats --verbose "::{now}" /usr/share/nginx/static

          echo "Pruning"
          {{ bbclient_all }} prune --stats --keep-within=100d --keep-weekly=-1

          echo "Compacting"
          {{ bbclient_all }} compact --verbose

        ''
        }
    ]
  }
]
