-- Auto-generated from edctl.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, groups : Text, append : Bool })
    , register : Optional Text
    , file : Optional ({ path : Text, mode : Optional Text, owner : Optional Text, group : Optional Text, state : Optional Text })
    , loop : Optional (List Text)
    , become : Optional Bool
    , become_user : Optional Text
    , `community.general.docker_login` : Optional ({ registry_url : Text, username : Text, password : Text })
    , when : Optional Text
    , pip : Optional ({ virtualenv : Text, name : List Text })
    , copy : Optional ({ src : Text, dest : Text, mode : Text, force : Text })
    , authorized_key : Optional ({ user : Text, key_options : Text, key : Text })
  }
    , default =
        { user = None ({ name : Text, home : Text, groups : Text, append : Bool })
    , register = None Text
    , file = None ({ path : Text, mode : Optional Text, owner : Optional Text, group : Optional Text, state : Optional Text })
    , loop = None (List Text)
    , become = None Bool
    , become_user = None Text
    , `community.general.docker_login` = None ({ registry_url : Text, username : Text, password : Text })
    , when = None Text
    , pip = None ({ virtualenv : Text, name : List Text })
    , copy = None ({ src : Text, dest : Text, mode : Text, force : Text })
    , authorized_key = None ({ user : Text, key_options : Text, key : Text })
  }
    }

in  [
    Task::{
      name = "Create edctl user",
      user = Some {
        name = "edctl"
      , home = "/opt/edctl"
      , groups = "docker"
      , append = True
    },
      register = Some "_user"
    }
  , Task::{
      name = "Change access rights on /opt/edctl",
      file = Some {
        path = "/opt/edctl"
      , mode = Some "0700"
      , owner = None Text
      , group = None Text
      , state = None Text
    }
    }
  , Task::{
      name = "Change access rights on template directories",
      file = Some {
        path = "{{ item }}"
      , mode = None Text
      , owner = Some "{{ _user.uid }}"
      , group = Some "{{ _user.group }}"
      , state = None Text
    },
      loop = Some [
        "/docker/exploredata.test/jupyterhub_home/templates"
      , "/docker/exploredata.prod/jupyterhub_home/templates"
    ]
    }
  , Task::{
      name = "Login to registry",
      become = Some True,
      become_user = Some "edctl",
      `community.general.docker_login` = Some {
        registry_url = "{{ jbuild_registry.url }}"
      , username = "{{ jbuild_registry.username }}"
      , password = "{{ jbuild_registry.password }}"
    }
    }
  , Task::{
      name = "Remove virtual env",
      file = Some {
        path = "/opt/edctl/venv"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , state = Some "absent"
    },
      when = Some "virtualenv_recreate | default(False) | bool"
    }
  , Task::{
      name = "Create virtual env",
      pip = Some { virtualenv = "/opt/edctl/venv", name = [ "click", "docker" ] }
    }
  , Task::{
      name = "Copy edctl.py",
      copy = Some {
        src = "edctl.py"
      , dest = "/opt/edctl/edctl.py"
      , mode = "+x"
      , force = "{{ jbuild_force | default(True) | bool }}"
    }
    }
  , Task::{
      name = "Add keys to authorized_keys",
      authorized_key = Some {
        user = "edctl"
      , key_options = "command=\"/opt/edctl/edctl.py\""
      , key = ''
        {% for elt in _jbuild_user_keys.results -%}
        {{ elt.public_key }}
        {% endfor %}

      ''
    }
    }
]
