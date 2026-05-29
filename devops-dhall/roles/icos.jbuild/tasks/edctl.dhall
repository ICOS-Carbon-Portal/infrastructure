-- Auto-generated from ../../../../devops/roles/icos.jbuild/tasks/edctl.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create edctl user",
      user = Some {
        name = "edctl",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = None Text,
        home = Some "/opt/edctl",
        password_lock = None Bool,
        groups = Some [ "docker" ],
        append = Some "True",
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    },
      register = Some "_user"
    }
  , Task::{
      name = Some "Change access rights on /opt/edctl",
      file = Some (Task.Poly_file.Record {
          path = Some "/opt/edctl",
          state = None Text,
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "0700",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Change access rights on template directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ item }}",
          state = None Text,
          owner = Some "{{ _user.uid }}",
          group = Some "{{ _user.group }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      loop = Some (Task.Poly_loop.Texts [
          "/docker/exploredata.test/jupyterhub_home/templates"
        , "/docker/exploredata.prod/jupyterhub_home/templates"
      ])
    }
  , Task::{
      name = Some "Login to registry",
      become = Some (Task.Poly_become.Bool True),
      become_user = Some "edctl",
      `community.general.docker_login` = Some {
        registry_url = "{{ jbuild_registry.url }}",
        username = "{{ jbuild_registry.username }}",
        password = "{{ jbuild_registry.password }}"
    }
    }
  , Task::{
      name = Some "Remove virtual env",
      file = Some (Task.Poly_file.Record {
          path = Some "/opt/edctl/venv",
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      when = Some [ "virtualenv_recreate | default(False) | bool" ]
    }
  , Task::{
      name = Some "Create virtual env",
      pip = Some (Task.Poly_pip.Record { name = [ "click", "docker" ], virtualenv = Some "/opt/edctl/venv", state = None Text })
    }
  , Task::{
      name = Some "Copy edctl.py",
      copy = Some {
        dest = "/opt/edctl/edctl.py",
        mode = Some "+x",
        content = None Text,
        src = Some "edctl.py",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = Some "{{ jbuild_force | default(True) | bool }}",
        validate = None Text
    }
    }
  , Task::{
      name = Some "Add keys to authorized_keys",
      authorized_key = Some {
        user = "edctl",
        key = ''
        {% for elt in _jbuild_user_keys.results -%}
        {{ elt.public_key }}
        {% endfor %}

      '',
        state = None Text,
        exclusive = None Bool,
        key_options = Some "command=\"/opt/edctl/edctl.py\""
    }
    }
]
