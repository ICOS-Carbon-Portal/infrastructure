-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add rspam apt key",
      apt_key = Some {
        id = None Text
      , url = "https://rspamd.com/apt-stable/gpg.key"
      , state = "present"
    }
    }
  , Task::{
      name = Some "Add rspamd apt repository",
      apt_repository = Some {
        filename = Some "rspamd"
      , repo = ''
        deb http://rspamd.com/apt-stable/ {{ ansible_distribution_release}} main

      ''
    }
    }
  , Task::{
      name = Some "Install rspamd",
      apt = Some {
        name = Some [ "rspamd" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = Some False
    }
    }
]
