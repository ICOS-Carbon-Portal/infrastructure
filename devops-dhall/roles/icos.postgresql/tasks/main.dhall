-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : Text
    , when : Optional Text
  }
    , default =
        { when = None Text
  }
    }

in  [
    Item::{ import_tasks = "install.yml", tags = "postgresql_install" }
  , Item::{ import_tasks = "config.yml", tags = "postgresql_config" }
  , Item::{
      import_tasks = "pg_stat.yml",
      tags = "postgresql_pg_stat",
      when = Some "postgresql_pg_stat_enable"
    }
  , Item::{ import_tasks = "util.yml", tags = "postgresql_util" }
]
