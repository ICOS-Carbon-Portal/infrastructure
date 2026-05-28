-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, shell : Text })
    , copy : Optional ({ src : Text, dest : Text, owner : Text })
  }
    , default =
        { user = None ({ name : Text, home : Text, shell : Text })
    , copy = None ({ src : Text, dest : Text, owner : Text })
  }
    }

in  [
    Task::{
      name = "Create cpauth user",
      user = Some { name = "{{ cpauth_user }}", home = "{{ cpauth_home }}", shell = "/bin/bash" }
    }
  , Task::{
      name = "Copy keys",
      copy = Some { src = "privateKeys", dest = "{{ cpauth_home }}", owner = "{{ cpauth_user }}" }
    }
]
