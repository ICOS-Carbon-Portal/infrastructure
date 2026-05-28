-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , loop : Optional (List Text)
    , apt : Optional ({ name : Text })
    , file : Optional ({ path : Text, state : Text })
    , htpasswd : Optional ({ path : Text, name : Text, password : Text })
  }
    , default =
        { fail = None ({ msg : Text })
    , when = None Text
    , loop = None (List Text)
    , apt = None ({ name : Text })
    , file = None ({ path : Text, state : Text })
    , htpasswd = None ({ path : Text, name : Text, password : Text })
  }
    }

in  [
    Task::{
      name = "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [ "nginxauth_users", "nginxauth_name" ]
    }
  , Task::{ name = "Install apache2-utils", apt = Some { name = "apache2-utils" } }
  , Task::{ name = "Install the passlib library", apt = Some { name = "python3-passlib" } }
  , Task::{
      name = "Create directory for auth file",
      file = Some { path = "{{ nginxauth_file | dirname }}", state = "directory" }
    }
  , Task::{
      name = "Add basic auth users",
      loop = Some [ "{{ nginxauth_users }}" ],
      htpasswd = Some {
        path = "{{ nginxauth_file }}"
      , name = "{{ item.username }}"
      , password = "{{ item.password }}"
    }
    }
]
