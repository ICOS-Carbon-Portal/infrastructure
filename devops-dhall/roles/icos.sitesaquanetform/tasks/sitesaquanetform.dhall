-- Auto-generated from sitesaquanetform.yml

let Entry =
    { Type =
        { name : Text
    , git : Optional ({ repo : Text, dest : Text, key_file : Text })
    , template : Optional ({ src : Text, dest : Text })
    , docker_compose : Optional ({ project_src : Text, state : Text, build : Bool })
    , notify : Optional Text
  }
    , default =
        { git = None ({ repo : Text, dest : Text, key_file : Text })
    , template = None ({ src : Text, dest : Text })
    , docker_compose = None ({ project_src : Text, state : Text, build : Bool })
    , notify = None Text
  }
    }

in  [
    Entry::{
      name = "Pull source from git",
      git = Some {
        repo = "{{ vault_aquanet_form_git_repo }}"
      , dest = "{{ project_dir }}/repo"
      , key_file = "{{ project_dir }}/.ssh/id_rsa"
    }
    }
  , Entry::{
      name = "Copy config",
      template = Some { src = "config.json", dest = "{{ project_dir }}/repo/" }
    }
  , Entry::{
      name = "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml.j2", dest = "{{ project_dir }}/docker-compose.yml" }
    }
  , Entry::{
      name = "Run docker-compose",
      docker_compose = Some { project_src = "{{ project_dir }}", state = "present", build = True },
      notify = Some "reload nginx config"
    }
]
