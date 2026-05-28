-- Auto-generated from auth.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , apt : Optional ({ name : Text })
    , htpasswd : Optional ({ path : Text, name : Text, password : Text, crypt_scheme : Text })
    , loop : Optional Text
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , apt = None ({ name : Text })
    , htpasswd = None ({ path : Text, name : Text, password : Text, crypt_scheme : Text })
    , loop = None Text
  }
    }

in  [
    Task::{
      name = "Create auth directory",
      file = Some { path = "{{ registry_htpasswd_file | dirname }}", state = "directory" }
    }
  , Task::{ name = "Install the passlib library", apt = Some { name = "python3-passlib" } }
  , Task::{
      name = "Add basic auth users",
      htpasswd = Some {
        path = "{{ registry_htpasswd_file }}"
      , name = "{{ item.name }}"
      , password = "{{ item.password }}"
      , crypt_scheme = "bcrypt"
    },
      loop = Some "{{ registry_users }}"
    }
]
