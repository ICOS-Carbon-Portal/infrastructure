-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , `assert` : Optional ({ that : Text, quiet : Bool })
    , copy : Optional ({ dest : Text, src : Optional Text, content : Optional Text })
    , loop : Optional (List Text)
    , template : Optional ({ src : Text, dest : Text, backup : Bool, validate : Text })
    , tags : Optional Text
    , `community.general.docker_login` : Optional ({ registry_url : Text, username : Text, password : Text })
    , `community.docker.docker_image` : Optional ({ name : Text, source : Text })
    , docker_compose : Optional ({ project_src : Text, build : Bool })
  }
    , default =
        { `assert` = None ({ that : Text, quiet : Bool })
    , copy = None ({ dest : Text, src : Optional Text, content : Optional Text })
    , loop = None (List Text)
    , template = None ({ src : Text, dest : Text, backup : Bool, validate : Text })
    , tags = None Text
    , `community.general.docker_login` = None ({ registry_url : Text, username : Text, password : Text })
    , `community.docker.docker_image` = None ({ name : Text, source : Text })
    , docker_compose = None ({ project_src : Text, build : Bool })
  }
    }

in  [
    Task::{
      name = "Check type of deployment",
      `assert` = Some { that = "exploredata_type in ('prod', 'test')", quiet = True }
    }
  , Task::{
      name = "Copy files",
      copy = Some { dest = "{{ exploredata_home }}/", src = Some "{{ item }}", content = None Text },
      loop = Some [ "build.hub", "jupyterhub_home", "docker-compose.yml" ]
    }
  , Task::{
      name = "Copy jupyterhub_config.py",
      template = Some {
        src = "jupyterhub_config.py"
      , dest = "{{ exploredata_home }}/jupyterhub_home/"
      , backup = True
      , validate = "python3 -m py_compile %s"
    }
    }
  , Task::{
      name = "Install runtime environment file",
      copy = Some {
        dest = "{{ exploredata_home }}/.env"
      , src = None Text
      , content = Some ''
        NETWORK_NAME={{ exploredata_network }}
        HUB_PORT={{ exploredata_port }}
        HUB_RESTART=always
        HUB_IMAGE={{ exploredata_hub_image }}
        HUB_CONTAINER_NAME={{ exploredata_hub_container }}
        NOTEBOOK_IMAGE={{ exploredata_notebook_image }}
        PASSWORD={{ exploredata_password[exploredata_type] }}

      ''
    }
    }
  , Task::{
      name = "Login to registry",
      tags = Some "docker_login",
      `community.general.docker_login` = Some {
        registry_url = "{{ registry_domain }}"
      , username = "docker"
      , password = "{{ vault_registry_pass }}"
    }
    }
  , Task::{
      name = "Make sure that the notebook images are present",
      `community.docker.docker_image` = Some { name = "{{ exploredata_notebook_image }}", source = "pull" }
    }
  , Task::{
      name = "Build and start the hub image",
      docker_compose = Some { project_src = "{{ exploredata_home }}", build = True }
    }
]
