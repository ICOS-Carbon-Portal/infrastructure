-- Auto-generated from ../devops/cpauth.yml

let Task = ./types/Task.dhall

in  [
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
        Task::{
          name = Some "Install cpauth backup",
          tags = Some [ "backup" ],
          import_role = Some (Task.Poly_import_role.Record { name = "icos.cpauth", tasks_from = Some "backup" })
        }
    ]
  }
]
