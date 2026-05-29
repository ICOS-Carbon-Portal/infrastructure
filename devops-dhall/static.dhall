-- Auto-generated from ../devops/static.yml

[
    {
      hosts = "fsicos2"
    , vars = {
        bbclient_home = "/opt/bbclient-nginx-static"
      , backup_script = "{{ bbclient_home }}/backup.sh"
    }
    , roles = [
        {
          role = "icos.nginxsite",
          tags = "static",
          vars = Some { nginxsite_name = "static", nginxsite_file = "files/domains/static.conf" },
          bbclient_name = None Text,
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.bbclient2",
          tags = "bbclient",
          vars = None ({ nginxsite_name : Text, nginxsite_file : Text }),
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
