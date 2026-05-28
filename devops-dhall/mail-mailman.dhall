-- Auto-generated from mail-mailman.yml

[
    {
      hosts = "fsicos2"
    , vars = {
        mailman_rest_pass = "{{ vault_mailman_rest_pass }}"
      , mailman_rest_allow_deny = "{{ vault_mailman_rest_allow_deny }}"
      , mailman_domains = [
          "lists.icos-ri.eu"
        , "lists.eric-forum.eu"
        , "lists.icos-cities.eu"
        , "lists.kadi-project.eu"
      ]
    }
    , roles = [
        {
          role = "icos.mailman",
          tags = "mailman",
          vars = None ({ bbclient_name : Text, bbclient_user : Text, bbclient_home : Text, bbclient_coldbackup : Text, bbclient_remotes : List Text })
        }
      , {
          role = "icos.bbclient2",
          tags = "bbclient",
          vars = Some {
            bbclient_name = "mailman"
          , bbclient_user = "root"
          , bbclient_home = "{{ mailman_home }}/bbclient"
          , bbclient_coldbackup = "{{ mailman_home }}"
          , bbclient_remotes = [ "fsicos2", "icos1" ]
        }
        }
    ]
    , tasks = [
        {
          name = "Install proxy for mailman"
        , tags = "proxy"
        , import_role = { name = "icos.mailman", tasks_from = "proxy" }
      }
    ]
  }
]
