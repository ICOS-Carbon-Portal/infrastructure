-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install public keys",
      authorized_key = Some {
        user = "root"
      , key_options = None Text
      , key = "{{ root_keys }}"
      , state = Some "present"
      , exclusive = Some True
    },
      when = Some [ "root_keys is truthy" ]
    }
  , Task::{
      name = Some "Set timezone to Europe/Stockholm",
      timezone = Some { name = "Europe/Stockholm" },
      notify = Some [ "restart cron" ]
    }
  , Task::{
      name = Some "Generate locale",
      locale_gen = Some { name = "{{ item }}", state = "present" },
      loop = Some [ "en_US.UTF-8", "sv_SE.UTF-8" ]
    }
]
