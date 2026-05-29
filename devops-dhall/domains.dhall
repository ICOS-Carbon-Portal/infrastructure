-- Auto-generated from ../devops/domains.yml

[
    {
      hosts = "fsicos2"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , certbot_name : Optional Text
        , certbot_domains : Optional (List Text)
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , vars : Optional ({ nginxsite_name : Text, nginxsite_file : Text })
      }
        , default =
            { certbot_name = None Text
        , certbot_domains = None (List Text)
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , vars = None ({ nginxsite_name : Text, nginxsite_file : Text })
      }
        }

    in  [
        Role::{
          role = "icos.certbot2",
          tags = "icos-ri",
          certbot_name = Some "icos-ri.eu",
          certbot_domains = Some [ "icos-ri.eu", "www.icos-ri.eu", "conference.icos-ri.eu" ]
        }
      , Role::{
          role = "icos.nginxsite",
          tags = "icos-ri",
          nginxsite_name = Some "icos-ri",
          nginxsite_file = Some "files/domains/icos-ri.conf"
        }
      , Role::{
          role = "icos.certbot2",
          tags = "icos-cities",
          certbot_name = Some "icos-cities",
          certbot_domains = Some [ "paul.icos-cp.eu", "paul.icos-ri.eu", "icos-cities.eu", "www.icos-cities.eu" ]
        }
      , Role::{
          role = "icos.nginxsite",
          tags = "icos-cities",
          vars = Some {
            nginxsite_name = "icos-cities"
          , nginxsite_file = "files/domains/icos-cities.conf"
        }
        }
    ]
  }
]
