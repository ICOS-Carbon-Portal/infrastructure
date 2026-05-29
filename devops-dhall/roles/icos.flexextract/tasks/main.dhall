-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create flexextract user",
      user = Some {
        name = "{{ flexextract_user }}"
      , home = Some "{{ flexextract_home | default(omit) }}"
      , create_home = None Text
      , shell = Some "/bin/bash"
      , groups = Some [ "docker" ]
      , append = Some "True"
      , state = None Text
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
  , Task::{
      name = Some "Add passwordless sudo for flexextract",
      copy = Some {
        src = None Text
      , dest = "/etc/sudoers.d/flexextract"
      , mode = None Text
      , content = Some ''
        flexextract ALL = NOPASSWD: ALL

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      import_tasks = Some "flexextract.yml",
      become = Some "True",
      become_user = Some "flexextract"
    }
]
