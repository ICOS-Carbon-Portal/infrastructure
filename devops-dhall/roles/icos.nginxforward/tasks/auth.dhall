-- Auto-generated from auth.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text, state : Optional Text })
    , htpasswd : Optional ({ path : Text, name : Text, password : Text })
    , loop : Optional Text
  }
    , default =
        { apt = None ({ name : Text, state : Optional Text })
    , htpasswd = None ({ path : Text, name : Text, password : Text })
    , loop = None Text
  }
    }

in  [
    Task::{
      name = "Install apache2-utils",
      apt = Some { name = "apache2-utils", state = Some "present" }
    }
  , Task::{
      name = "Install the passlib library",
      apt = Some { name = "python3-passlib", state = None Text }
    }
  , Task::{
      name = "Add basic auth users",
      htpasswd = Some {
        path = "{{ nginxforward_user_file }}"
      , name = "{{ item.name }}"
      , password = "{{ item.password }}"
    },
      loop = Some "{{ nginxforward_users }}"
    }
]
