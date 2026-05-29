-- Auto-generated from ../../../../devops/roles/icos.docker/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Make sure docker is upgraded if requested",
      when = Some [ "docker_upgrade | bool" ],
      dpkg_selections = Some { name = "{{ item }}", selection = "install" },
      loop = Some (Task.Poly_loop.Texts [ "docker.io", "containerd" ])
    }
  , Task::{
      name = Some "Install/upgrade docker",
      apt = Some {
        name = Some [ "docker.io", "containerd" ],
        state = Some "{{ \"latest\" if docker_upgrade | bool else \"present\" }}",
        update_cache = Some True,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Make sure docker isn't upgraded",
      dpkg_selections = Some {
        name = "{{ item }}",
        selection = "{{ 'hold' if docker_prevent_upgrade else 'install' }}"
    },
      loop = Some (Task.Poly_loop.Texts [ "docker.io", "containerd" ])
    }
  , Task::{
      name = Some "Install docker-compose",
      pip = Some (Task.Poly_pip.Record { name = [ "docker-compose" ], virtualenv = None Text, state = None Text })
    }
  , Task::{
      name = Some "Install docker configuration",
      copy = Some {
        dest = "/etc/docker/",
        mode = None Text,
        content = None Text,
        src = Some "daemon.json",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "reload docker" ]
    }
  , Task::{
      name = Some "Start docker",
      systemd = Some {
        name = Some "docker",
        state = Some "started",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      import_tasks = Some "cleanup.yml",
      tags = Some [ "docker_cleanup" ],
      when = Some [ "docker_periodic_cleanup" ]
    }
  , Task::{
      import_role = Some (Task.Poly_import_role.Str "name=icos.docker_utils"),
      tags = Some [ "docker_utils" ]
    }
]
