-- Auto-generated from ../devops/cpauth.yml

let Task = ./types/Task.dhall

in  [
    {
      hosts = "fsicos2"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , certbot_name : Optional Text
        , certbot_domains : Optional Text
      }
        , default =
            { certbot_name = None Text
        , certbot_domains = None Text
      }
        }

    in  [
        Role::{
          role = "icos.certbot2",
          tags = "cert",
          certbot_name = Some "{{ cpauth_cert_name }}",
          certbot_domains = Some "{{ cpauth_domains }}"
        }
      , Role::{ role = "icos.cpauth", tags = "cpauth" }
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
