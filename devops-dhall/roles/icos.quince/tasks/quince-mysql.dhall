-- Auto-generated from quince-mysql.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text, state : Text })
    , loop : Optional (List Text)
    , mysql_db : Optional ({ name : Text, state : Text, login_unix_socket : Text })
    , mysql_user : Optional ({ name : Text, password : Text, priv : Text, state : Text, login_unix_socket : Text })
  }
    , default =
        { apt = None ({ name : Text, state : Text })
    , loop = None (List Text)
    , mysql_db = None ({ name : Text, state : Text, login_unix_socket : Text })
    , mysql_user = None ({ name : Text, password : Text, priv : Text, state : Text, login_unix_socket : Text })
  }
    }

in  [
    Task::{
      name = "Install MySQL",
      apt = Some { name = "{{ item }}", state = "present" },
      loop = Some [ "mysql-server", "python3-pymysql" ]
    }
  , Task::{
      name = "Create quince database",
      mysql_db = Some {
        name = "quince"
      , state = "present"
      , login_unix_socket = "/var/run/mysqld/mysqld.sock"
    }
    }
  , Task::{
      name = "Create quince database user",
      mysql_user = Some {
        name = "quince"
      , password = "quince"
      , priv = "*.*:ALL"
      , state = "present"
      , login_unix_socket = "/var/run/mysqld/mysqld.sock"
    }
    }
]
