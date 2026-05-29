-- Auto-generated from ../devops/all.yml

let Task = ./types/Task.dhall

in  [
    {
      hosts = "all"
    , roles = [
        { role = "icos.utils", tags = "utils" }
    ]
    , tasks = [
        Task::{
          name = Some "Install public key",
          tags = Some [ "root_keys" ],
          authorized_key = Some {
            user = "root",
            key = "{{ root_keys }}",
            state = Some "present",
            exclusive = Some True,
            key_options = None Text
        }
        }
    ]
  }
]
