-- Auto-generated from nexus.yml

[
    {
      hosts = "fsicos2"
    , roles = [
        {
          role = "icos.nexus",
          tags = "nexus",
          bbclient_name = None Text,
          bbclient_user = None Text,
          bbclient_home = None Text,
          bbclient_coldbackup = None Text
        }
      , {
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
