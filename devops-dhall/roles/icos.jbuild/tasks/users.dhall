-- Auto-generated from ../../../../devops/roles/icos.jbuild/tasks/users.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Generate keys for jbuild",
      openssh_keypair = Some { path = "/home/{{ item }}/.ssh/jbuild", owner = "{{ item }}", group = "{{ item }}" },
      loop = Some (Task.Poly_loop.Str "{{ jbuild_users }}"),
      register = Some "_jbuild_user_keys"
    }
  , Task::{
      name = Some "Generate jbuild ssh config",
      blockinfile = Some {
        path = "/home/{{ item }}/.ssh/config",
        create = Some True,
        marker = "# {mark} ansible / jbuild",
        block = Some ''
        Host edctl
          Hostname {{ jbuild_edctl_host_name }}
          Port {{ jbuild_edctl_host_port }}
          User edctl
          IdentityFile ~/.ssh/jbuild

        Host jyctl
          Hostname {{ jbuild_jyctl_host_name }}
          Port {{ jbuild_jyctl_host_port }}
          User jyctl
          IdentityFile ~/.ssh/jbuild

        Host projectcommon
          Hostname {{ jbuild_rsync_host_name }}
          Port {{ jbuild_rsync_host_port }}
          User project
          IdentityFile ~/.ssh/jbuild

      '',
        insertafter = Some "EOF",
        insertbefore = None Text,
        state = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ jbuild_users }}")
    }
  , Task::{
      name = Some "Create $HOME/bin directory",
      file = Some (Task.Poly_file.Record {
          path = Some "/home/{{ item }}/bin",
          state = Some "directory",
          owner = Some "{{ item }}",
          group = Some "{{ item }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      loop = Some (Task.Poly_loop.Str "{{ jbuild_users }}")
    }
  , Task::{
      name = Some "Create wrappers for edctl",
      copy = Some {
        dest = "/home/{{ item }}/bin/edctl",
        mode = Some "+x",
        content = Some ''
        #!/bin/bash
        ssh edctl /opt/edctl/edctl.py "$@"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ jbuild_users }}")
    }
  , Task::{
      name = Some "Create wrappers for jyctl",
      copy = Some {
        dest = "/home/{{ item }}/bin/jyctl",
        mode = Some "+x",
        content = Some ''
        #!/bin/bash
        ssh jyctl /opt/jyctl/jyctl.py "$@"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ jbuild_users }}")
    }
  , Task::{
      name = Some "Login to registry",
      become = Some (Task.Poly_become.Bool True),
      become_user = Some "{{ item }}",
      `community.general.docker_login` = Some {
        registry_url = "{{ registry_domain }}",
        username = "docker",
        password = "{{ jbuild_registry_pass }}"
    },
      loop = Some (Task.Poly_loop.Str "{{ jbuild_users }}")
    }
]
