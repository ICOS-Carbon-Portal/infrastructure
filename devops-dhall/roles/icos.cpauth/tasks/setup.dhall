-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create cpauth user",
      user = Some {
        name = "{{ cpauth_user }}"
      , home = Some "{{ cpauth_home }}"
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
  , Task::{
      name = Some "Copy keys",
      copy = Some {
        src = Some "privateKeys"
      , dest = "{{ cpauth_home }}"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = Some "{{ cpauth_user }}"
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
