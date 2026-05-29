-- Auto-generated from ../devops/nexus.yml

[
    {
      hosts = "fsicos2"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , bbclient_name : Optional Text
        , bbclient_user : Optional Text
        , bbclient_home : Optional Text
        , bbclient_coldbackup : Optional Text
      }
        , default =
            { bbclient_name = None Text
        , bbclient_user = None Text
        , bbclient_home = None Text
        , bbclient_coldbackup = None Text
      }
        }

    in  [
        Role::{ role = "icos.nexus", tags = "nexus" }
      , Role::{
          role = "icos.bbclient2",
          tags = "bbclient",
          bbclient_name = Some "nexus",
          bbclient_user = Some "root",
          bbclient_home = Some "{{ nexus_home }}/bbclient",
          bbclient_coldbackup = Some "{{ nexus_home }}"
        }
    ]
  }
]
