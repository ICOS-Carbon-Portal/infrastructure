-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create doi user",
      user = Some {
        name = "{{ doi_user }}"
      , home = Some "{{ doi_home }}"
      , create_home = None Text
      , shell = Some "/bin/bash"
      , groups = None (List Text)
      , append = None Text
      , state = None Text
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
]
