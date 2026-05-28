-- Auto-generated from cpauth.yml

[
    {
      hosts = "fsicos2"
    , roles = [
        {
          role = "icos.certbot2",
          tags = "cert",
          certbot_name = Some "{{ cpauth_cert_name }}",
          certbot_domains = Some "{{ cpauth_domains }}"
        }
      , {
          role = "icos.cpauth",
          tags = "cpauth",
          certbot_name = None Text,
          certbot_domains = None Text
        }
    ]
    , tasks = [
        {
          name = "Install cpauth backup"
        , tags = "backup"
        , import_role = { name = "icos.cpauth", tasks_from = "backup" }
      }
    ]
  }
]
