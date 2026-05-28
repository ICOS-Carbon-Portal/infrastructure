-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , user : Optional ({ name : Text, home : Text, shell : Text, groups : Text, append : Bool })
    , copy : Optional ({ dest : Text, content : Text })
    , import_tasks : Optional Text
    , become : Optional Bool
    , become_user : Optional Text
  }
    , default =
        { name = None Text
    , user = None ({ name : Text, home : Text, shell : Text, groups : Text, append : Bool })
    , copy = None ({ dest : Text, content : Text })
    , import_tasks = None Text
    , become = None Bool
    , become_user = None Text
  }
    }

in  [
    Item::{
      name = Some "Create flexextract user",
      user = Some {
        name = "{{ flexextract_user }}"
      , home = "{{ flexextract_home | default(omit) }}"
      , shell = "/bin/bash"
      , groups = "docker"
      , append = True
    }
    }
  , Item::{
      name = Some "Add passwordless sudo for flexextract",
      copy = Some {
        dest = "/etc/sudoers.d/flexextract"
      , content = ''
        flexextract ALL = NOPASSWD: ALL

      ''
    }
    }
  , Item::{
      import_tasks = Some "flexextract.yml",
      become = Some True,
      become_user = Some "flexextract"
    }
]
