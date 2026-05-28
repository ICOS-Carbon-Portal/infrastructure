-- Auto-generated from jyctl.yml

let Item =
    { Type =
        { import_role : Optional Text
    , name : Optional Text
    , user : Optional ({ name : Text, home : Text, groups : Text, append : Bool })
    , register : Optional Text
    , file : Optional ({ path : Text, owner : Optional Text, group : Optional Text, mode : Optional Text, state : Optional Text })
    , loop : Optional (List Text)
    , become : Optional Bool
    , become_user : Optional Text
    , `community.general.docker_login` : Optional ({ registry_url : Text, username : Text, password : Text })
    , when : Optional Text
    , pip : Optional ({ virtualenv : Text, name : List Text, state : Text })
    , copy : Optional ({ src : Optional Text, dest : Text, mode : Optional Text, force : Optional Text, content : Optional Text })
    , authorized_key : Optional ({ user : Text, key_options : Text, key : Text })
    , notify : Optional Text
  }
    , default =
        { import_role = None Text
    , name = None Text
    , user = None ({ name : Text, home : Text, groups : Text, append : Bool })
    , register = None Text
    , file = None ({ path : Text, owner : Optional Text, group : Optional Text, mode : Optional Text, state : Optional Text })
    , loop = None (List Text)
    , become = None Bool
    , become_user = None Text
    , `community.general.docker_login` = None ({ registry_url : Text, username : Text, password : Text })
    , when = None Text
    , pip = None ({ virtualenv : Text, name : List Text, state : Text })
    , copy = None ({ src : Optional Text, dest : Text, mode : Optional Text, force : Optional Text, content : Optional Text })
    , authorized_key = None ({ user : Text, key_options : Text, key : Text })
    , notify = None Text
  }
    }

in  [
    Item::{ import_role = Some "name=icos.python3" }
  , Item::{
      name = Some "Create jyctl user",
      user = Some {
        name = "jyctl"
      , home = "/opt/jyctl"
      , groups = "docker"
      , append = True
    },
      register = Some "_user"
    }
  , Item::{
      name = Some "Change access rights on template directory",
      file = Some {
        path = "{{ item }}"
      , owner = Some "{{ _user.uid }}"
      , group = Some "{{ _user.group }}"
      , mode = None Text
      , state = None Text
    },
      loop = Some [ "/docker/jupyter/jupyterhub_home/templates" ]
    }
  , Item::{
      name = Some "Change access rights on /opt/jyctl",
      file = Some {
        path = "/opt/jyctl"
      , owner = None Text
      , group = None Text
      , mode = Some "0700"
      , state = None Text
    }
    }
  , Item::{
      name = Some "Login to registry",
      become = Some True,
      become_user = Some "jyctl",
      `community.general.docker_login` = Some {
        registry_url = "{{ jbuild_registry.url }}"
      , username = "{{ jbuild_registry.username }}"
      , password = "{{ jbuild_registry.password }}"
    }
    }
  , Item::{
      name = Some "Remove virtual env",
      file = Some {
        path = "/opt/jyctl/venv"
      , owner = None Text
      , group = None Text
      , mode = None Text
      , state = Some "absent"
    },
      when = Some "virtualenv_recreate | default(False) | bool"
    }
  , Item::{
      name = Some "Create virtual env",
      pip = Some { virtualenv = "/opt/jyctl/venv", name = [ "click", "docker" ], state = "present" }
    }
  , Item::{
      name = Some "Copy jyctl.py",
      copy = Some {
        src = Some "jyctl.py"
      , dest = "/opt/jyctl/jyctl.py"
      , mode = Some "+x"
      , force = Some "{{ jbuild_force | default(True) | bool }}"
      , content = None Text
    }
    }
  , Item::{
      name = Some "Add keys to authorized_keys",
      authorized_key = Some {
        user = "jyctl"
      , key_options = "command=\"/opt/jyctl/jyctl.py\""
      , key = ''
        {% for elt in _jbuild_user_keys.results -%}
        {{ elt.public_key }}
        {% endfor %}

      ''
    }
    }
  , Item::{
      name = Some "Allow jyctl to login",
      copy = Some {
        src = None Text
      , dest = "/etc/ssh/sshd_config.d/jyctl_allow_users.conf"
      , mode = None Text
      , force = None Text
      , content = Some ''
        AllowUsers jyctl

      ''
    },
      notify = Some "reload sshd"
    }
]
