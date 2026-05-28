-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional (List Text)
    , name : Optional Text
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
    , block : Optional (List ({ name : Text, copy : Optional ({ src : Text, dest : Text }), shell : Optional Text }))
  }
    , default =
        { import_tasks = None Text
    , tags = None (List Text)
    , name = None Text
    , include_role = None ({ name : Text })
    , vars = None ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
    , block = None (List ({ name : Text, copy : Optional ({ src : Text, dest : Text }), shell : Optional Text }))
  }
    }

in  [
    Item::{ import_tasks = Some "docker.yml", tags = Some [ "onlyoffice_docker" ] }
  , Item::{
      name = Some "Install nginx configuration for onlyoffice",
      include_role = Some { name = "icos.nginxsite" },
      vars = Some {
        nginxsite_name = "onlyoffice"
      , nginxsite_file = "onlyoffice.conf"
      , nginxsite_domains = [ "{{ onlyoffice_domain }}" ]
    }
    }
  , Item::{ import_tasks = Some "just.yml", tags = Some [ "onlyoffice_just" ] }
  , Item::{
      tags = Some [ "onlyoffice_install_fonts", "onlyoffice_docker" ],
      name = Some "Install onlyoffice fonts inside container",
      block = Some [
        {
          name = "Copy fonts directory to docker host",
          copy = Some { src = "fonts/", dest = "{{ onlyoffice_home }}/fonts/" },
          shell = None Text
        }
      , {
          name = "Copy fonts into container and refresh font cache",
          copy = None ({ src : Text, dest : Text }),
          shell = Some ''
          docker cp {{ onlyoffice_home }}/fonts/. onlyoffice:/usr/share/fonts/truetype/custom/
          docker exec onlyoffice bash -lc 'fc-cache -f -v && /usr/bin/documentserver-generate-allfonts.sh'

        ''
        }
    ]
    }
]
