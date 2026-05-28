-- Auto-generated from registry.yml

let Entry =
    { Type =
        { name : Text
    , tags : Optional Text
    , become : Optional Bool
    , become_user : Optional Text
    , `community.general.docker_login` : Optional ({ registry_url : Text, username : Text, password : Text })
    , docker_image : Optional ({ name : Text, source : Text })
    , vars : Optional ({ conf : Text })
  }
    , default =
        { tags = None Text
    , become = None Bool
    , become_user = None Text
    , `community.general.docker_login` = None ({ registry_url : Text, username : Text, password : Text })
    , docker_image = None ({ name : Text, source : Text })
    , vars = None ({ conf : Text })
  }
    }

in  [
    Entry::{
      name = "Login to registry",
      tags = Some "login",
      become = Some True,
      become_user = Some "root",
      `community.general.docker_login` = Some {
        registry_url = "registry.icos-cp.eu"
      , username = "docker"
      , password = "{{ vault_registry_pass }}"
    }
    }
  , Entry::{
      name = "Pull the notebook image from registry",
      docker_image = Some { name = "{{ conf.image }}", source = "pull" },
      vars = Some { conf = "{{ jupyter_hub_config_defaults | combine(jupyter_hub_config) }}" }
    }
]
