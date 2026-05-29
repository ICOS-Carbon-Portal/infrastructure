-- Auto-generated from edctl.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create edctl user",
      user = Some {
        name = "edctl"
      , home = Some "/opt/edctl"
      , create_home = None Text
      , shell = None Text
      , groups = Some [ "docker" ]
      , append = Some "True"
      , state = None Text
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    },
      register = Some "_user"
    }
  , Task::{
      name = Some "Change access rights on /opt/edctl",
      file = Some {
        path = Some "/opt/edctl"
      , state = None Text
      , mode = Some "0700"
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Change access rights on template directories",
      file = Some {
        path = Some "{{ item }}"
      , state = None Text
      , mode = None Text
      , owner = Some "{{ _user.uid }}"
      , group = Some "{{ _user.group }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      loop = Some [
        "/docker/exploredata.test/jupyterhub_home/templates"
      , "/docker/exploredata.prod/jupyterhub_home/templates"
    ]
    }
  , Task::{
      name = Some "Login to registry",
      become = Some "True",
      become_user = Some "edctl",
      `community.general.docker_login` = Some {
        registry_url = "{{ jbuild_registry.url }}"
      , username = "{{ jbuild_registry.username }}"
      , password = "{{ jbuild_registry.password }}"
    }
    }
  , Task::{
      name = Some "Remove virtual env",
      file = Some {
        path = Some "/opt/edctl/venv"
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      when = Some [ "virtualenv_recreate | default(False) | bool" ]
    }
  , Task::{
      name = Some "Create virtual env",
      pip = Some {
        name = [ "click", "docker" ]
      , virtualenv = Some "/opt/edctl/venv"
      , state = None Text
    }
    }
  , Task::{
      name = Some "Copy edctl.py",
      copy = Some {
        src = Some "edctl.py"
      , dest = "/opt/edctl/edctl.py"
      , mode = Some "+x"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = Some "{{ jbuild_force | default(True) | bool }}"
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Add keys to authorized_keys",
      authorized_key = Some {
        user = "edctl"
      , key_options = Some "command=\"/opt/edctl/edctl.py\""
      , key = ''
        {% for elt in _jbuild_user_keys.results -%}
        {{ elt.public_key }}
        {% endfor %}

      ''
      , state = None Text
      , exclusive = None Bool
    }
    }
]
