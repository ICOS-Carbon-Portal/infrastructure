-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check type of deployment",
      `assert` = Some { that = [ "exploredata_type in ('prod', 'test')" ], quiet = Some True }
    }
  , Task::{
      name = Some "Copy files",
      copy = Some {
        src = Some "{{ item }}"
      , dest = "{{ exploredata_home }}/"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "build.hub", "jupyterhub_home", "docker-compose.yml" ]
    }
  , Task::{
      name = Some "Copy jupyterhub_config.py",
      template = Some {
        src = "jupyterhub_config.py"
      , dest = "{{ exploredata_home }}/jupyterhub_home/"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = Some "python3 -m py_compile %s"
      , backup = Some True
      , owner = None Text
      , group = None Text
    }
    }
  , Task::{
      name = Some "Install runtime environment file",
      copy = Some {
        src = None Text
      , dest = "{{ exploredata_home }}/.env"
      , mode = None Text
      , content = Some ''
        NETWORK_NAME={{ exploredata_network }}
        HUB_PORT={{ exploredata_port }}
        HUB_RESTART=always
        HUB_IMAGE={{ exploredata_hub_image }}
        HUB_CONTAINER_NAME={{ exploredata_hub_container }}
        NOTEBOOK_IMAGE={{ exploredata_notebook_image }}
        PASSWORD={{ exploredata_password[exploredata_type] }}

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Login to registry",
      tags = Some [ "docker_login" ],
      `community.general.docker_login` = Some {
        registry_url = "{{ registry_domain }}"
      , username = "docker"
      , password = "{{ vault_registry_pass }}"
    }
    }
  , Task::{
      name = Some "Make sure that the notebook images are present",
      `community.docker.docker_image` = Some { name = "{{ exploredata_notebook_image }}", source = "pull" }
    }
  , Task::{
      name = Some "Build and start the hub image",
      docker_compose = Some {
        project_src = "{{ exploredata_home }}"
      , build = Some True
      , restarted = None Text
      , state = None Text
    }
    }
]
