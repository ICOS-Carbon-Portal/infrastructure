-- Auto-generated from quince-mysql.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install MySQL",
      apt = Some {
        name = Some [ "{{ item }}" ]
      , state = Some "present"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    },
      loop = Some [ "mysql-server", "python3-pymysql" ]
    }
  , Task::{
      name = Some "Create quince database",
      mysql_db = Some {
        name = "quince"
      , state = "present"
      , login_unix_socket = "/var/run/mysqld/mysqld.sock"
    }
    }
  , Task::{
      name = Some "Create quince database user",
      mysql_user = Some {
        name = "quince"
      , password = "quince"
      , priv = "*.*:ALL"
      , state = "present"
      , login_unix_socket = "/var/run/mysqld/mysqld.sock"
    }
    }
]
