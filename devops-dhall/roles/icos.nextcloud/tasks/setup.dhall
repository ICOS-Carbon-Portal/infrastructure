-- Auto-generated from setup.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ path : Text, state : Text, mode : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ file : Text, set_fact : Text, file_var : Text })
    , loop : Optional (List Text)
    , template : Optional ({ src : Text, dest : Text })
    , command : Optional Text
    , args : Optional ({ chdir : Text })
    , changed_when : Optional Bool
    , cron : Optional ({ job : Text, hour : Text, minute : Text, name : Text })
  }
    , default =
        { name = None Text
    , file = None ({ path : Text, state : Text, mode : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ file : Text, set_fact : Text, file_var : Text })
    , loop = None (List Text)
    , template = None ({ src : Text, dest : Text })
    , command = None Text
    , args = None ({ chdir : Text })
    , changed_when = None Bool
    , cron = None ({ job : Text, hour : Text, minute : Text, name : Text })
  }
    }

in  [
    Item::{
      name = Some "Create nextcloud docker directory",
      file = Some { path = "{{ nextcloud_home }}", state = "directory", mode = "og-rw" }
    }
  , Item::{
      include_role = Some { name = "icos.password_env_file" },
      vars = Some {
        file = "{{ item.file }}"
      , set_fact = "{{ item.set_fact }}"
      , file_var = "{{ item.file_var }}"
    },
      loop = Some [
        {
          file = "{{ nextcloud_home }}/.pg-root-pass"
        , set_fact = "nextcloud_db_root_pass"
        , file_var = "POSTGRES_PASSWORD"
      }
      , {
          file = "{{ nextcloud_home }}/.pg-nextcloud-pass"
        , set_fact = "nextcloud_db_pass"
        , file_var = "NEXTCLOUD_PASSWORD"
      }
    ]
    }
  , Item::{
      name = Some "Copy files",
      loop = Some [
        "nextcloud.env"
      , "postgres.env"
      , "tweak.conf"
      , "init.sql"
      , "docker-compose.yml"
    ],
      template = Some { src = "{{ item }}", dest = "{{ nextcloud_home }}" }
    }
  , Item::{
      name = Some "Check docker-compose config",
      command = Some "docker-compose config",
      args = Some { chdir = "{{ nextcloud_home }}" },
      changed_when = Some False
    }
  , Item::{
      name = Some "Add nextcloud cron to crontab",
      cron = Some {
        job = "cd {{ nextcloud_home }} && docker compose exec -T -u www-data app php -f /var/www/html/cron.php || :"
      , hour = "*"
      , minute = "*/5"
      , name = "nextcloud_cron"
    }
    }
]
