-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , shell : Optional Text
    , args : Optional ({ chdir : Text, creates : Text })
    , docker_network : Optional ({ name : Text })
    , copy : Optional ({ dest : Text, src : Text })
    , loop : Optional (List Text)
    , template : Optional ({ src : Text, dest : Text })
    , vars : Optional ({ conf : Text })
    , register : Optional Text
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, services : Optional (List Text), state : Optional Text, build : Optional Text })
    , changed_when : Optional Bool
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , shell = None Text
    , args = None ({ chdir : Text, creates : Text })
    , docker_network = None ({ name : Text })
    , copy = None ({ dest : Text, src : Text })
    , loop = None (List Text)
    , template = None ({ src : Text, dest : Text })
    , vars = None ({ conf : Text })
    , register = None Text
    , `community.docker.docker_compose_v2` = None ({ project_src : Text, services : Optional (List Text), state : Optional Text, build : Optional Text })
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Create jupyter home",
      file = Some { path = "{{ jupyter_home }}", state = "directory" }
    }
  , Task::{
      name = "Create auth token",
      shell = Some "openssl rand -hex 20 | awk '{ print \"CONFIGPROXY_AUTH_TOKEN=\" $1 }' > auth_token.env",
      args = Some { chdir = "{{ jupyter_home }}", creates = "auth_token.env" }
    }
  , Task::{ name = "Create jupyter network", docker_network = Some { name = "jupyter" } }
  , Task::{
      name = "Copy files",
      copy = Some { dest = "{{ jupyter_home }}", src = "{{ item }}" },
      loop = Some [ "build.hub", "docker-compose.yml" ]
    }
  , Task::{
      name = "Copy jupyterhub_config.py",
      template = Some { src = "jupyterhub_config.py", dest = "{{ jupyter_home }}/jupyterhub_home/" },
      vars = Some { conf = "{{ jupyter_hub_config_defaults | combine(jupyter_hub_config) }}" },
      register = Some "_config"
    }
  , Task::{
      name = "Start proxy and hub",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ jupyter_home }}"
      , services = None (List Text)
      , state = None Text
      , build = None Text
    }
    }
  , Task::{
      name = "Restart the hub",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ jupyter_home }}"
      , services = Some [ "hub" ]
      , state = Some "restarted"
      , build = Some "always"
    },
      changed_when = Some False
    }
]
