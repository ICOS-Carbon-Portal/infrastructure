-- Auto-generated from ../devops/nextcloud.yml

[
    {
      hosts = "fsicos2"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , nextcloud_admin_password : Optional Text
        , nextcloud_domain : Optional Text
        , nextcloud_exporter_pass : Optional Text
        , nextcloud_volumes : Optional (List Text)
        , onlyoffice_domain : Optional Text
        , onlyoffice_secret : Optional Text
        , bbclient_name : Optional Text
        , bbclient_home : Optional Text
        , bbclient_coldbackup_hour : Optional Natural
        , bbclient_coldbackup_minute : Optional Natural
        , bbclient_coldbackup : Optional Text
        , bbclient_patterns : Optional Text
        , bbclient_remotes : Optional (List Text)
      }
        , default =
            { nextcloud_admin_password = None Text
        , nextcloud_domain = None Text
        , nextcloud_exporter_pass = None Text
        , nextcloud_volumes = None (List Text)
        , onlyoffice_domain = None Text
        , onlyoffice_secret = None Text
        , bbclient_name = None Text
        , bbclient_home = None Text
        , bbclient_coldbackup_hour = None Natural
        , bbclient_coldbackup_minute = None Natural
        , bbclient_coldbackup = None Text
        , bbclient_patterns = None Text
        , bbclient_remotes = None (List Text)
      }
        }

    in  [
        Role::{
          role = "icos.nextcloud",
          tags = "nextcloud",
          nextcloud_admin_password = Some "{{ vault_nextcloud_admin_password }}",
          nextcloud_domain = Some "fileshare.icos-cp.eu",
          nextcloud_exporter_pass = Some "{{ vault_nextcloud_exporter_pass }}",
          nextcloud_volumes = Some [ "/share/with_nextcloud:/share" ]
        }
      , Role::{
          role = "icos.onlyoffice",
          tags = "onlyoffice",
          onlyoffice_domain = Some "onlyoffice.icos-cp.eu",
          onlyoffice_secret = Some "{{ vault_onlyoffice_secret }}"
        }
      , Role::{
          role = "icos.bbclient2",
          tags = "bbclient",
          bbclient_name = Some "nextcloud",
          bbclient_home = Some "{{ nextcloud_home }}/bbclient",
          bbclient_coldbackup_hour = Some 1,
          bbclient_coldbackup_minute = Some 0,
          bbclient_coldbackup = Some "{{ nextcloud_home }}",
          bbclient_patterns = Some ''
          R /disk/data/nextcloud
          R /docker/nextcloud/volumes

        '',
          bbclient_remotes = Some [ "fsicos2", "icos1" ]
        }
    ]
  }
]
