-- Auto-generated from ../../../../devops/roles/icos.sitesaquanetform/tasks/sitesaquanetform.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Pull source from git",
      git = Some {
        repo = "{{ vault_aquanet_form_git_repo }}",
        version = None Text,
        dest = "{{ project_dir }}/repo",
        force = None Bool,
        update = None Text,
        key_file = Some "{{ project_dir }}/.ssh/id_rsa"
    }
    }
  , Task::{
      name = Some "Copy config",
      template = Some {
        src = "config.json",
        dest = "{{ project_dir }}/repo/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml.j2",
        dest = "{{ project_dir }}/docker-compose.yml",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Run docker-compose",
      docker_compose = Some {
        project_src = "{{ project_dir }}",
        build = Some True,
        restarted = None Text,
        state = Some "present"
    },
      notify = Some [ "reload nginx config" ]
    }
]
