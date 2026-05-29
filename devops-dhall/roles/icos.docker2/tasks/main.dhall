-- Auto-generated from ../../../../devops/roles/icos.docker2/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Fail if docker.io is apt-installed",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str ''
        dpkg --get-selections docker.io | grep -vq '\binstall'

      ''),
      changed_when = Some (Task.Poly_changed_when.Bool False),
      register = Some "r",
      failed_when = Some (Task.Poly_failed_when.Str "r.rc == 0")
    }
  , Task::{ import_tasks = Some "debian.yml", when = Some [ "ansible_distribution == \"Debian\"" ] }
  , Task::{ import_tasks = Some "ubuntu.yml", when = Some [ "ansible_distribution == \"Ubuntu\"" ] }
  , Task::{
      name = Some "Fail if we're not on a supported distribution",
      fail = Some { msg = "This role currently only support Debian and Ubuntu" },
      when = Some [ "ansible_distribution not in ('Debian', 'Ubuntu')" ]
    }
  , Task::{
      name = Some "Uninstall docker-compose version 1",
      apt = Some {
        name = Some [ "docker-compose" ],
        state = Some "absent",
        update_cache = None Bool,
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
      name = Some "Install docker and docker-compose",
      apt = Some {
        name = Some [
          "docker-ce"
        , "docker-ce-cli"
        , "containerd.io"
        , "docker-buildx-plugin"
        , "docker-compose-plugin"
      ],
        state = None Text,
        update_cache = None Bool,
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
      name = Some "Make sure docker is started",
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
      import_tasks = Some "cleanup.yml",
      tags = Some [ "docker_cleanup" ],
      when = Some [ "docker_periodic_cleanup" ]
    }
  , Task::{
      import_role = Some (Task.Poly_import_role.Str "name=icos.docker_utils"),
      tags = Some [ "docker_utils" ]
    }
  , Task::{ import_tasks = Some "test.yml", tags = Some [ "docker_test" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "docker_just" ] }
]
