-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , apt_key : Optional ({ url : Text, state : Text })
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , apt : Optional ({ name : Text, install_recommends : Bool })
  }
    , default =
        { apt_key = None ({ url : Text, state : Text })
    , apt_repository = None ({ filename : Text, repo : Text })
    , apt = None ({ name : Text, install_recommends : Bool })
  }
    }

in  [
    Task::{
      name = "Add rspam apt key",
      apt_key = Some { url = "https://rspamd.com/apt-stable/gpg.key", state = "present" }
    }
  , Task::{
      name = "Add rspamd apt repository",
      apt_repository = Some {
        filename = "rspamd"
      , repo = ''
        deb http://rspamd.com/apt-stable/ {{ ansible_distribution_release}} main

      ''
    }
    }
  , Task::{ name = "Install rspamd", apt = Some { name = "rspamd", install_recommends = False } }
]
