-- Auto-generated from users.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Generate keys for jbuild",
      openssh_keypair = Some {
        path = "/home/{{ item }}/.ssh/jbuild"
      , owner = "{{ item }}"
      , group = "{{ item }}"
    },
      loop = Some [ "{{ jbuild_users }}" ],
      register = Some "_jbuild_user_keys"
    }
  , Task::{
      name = Some "Generate jbuild ssh config",
      blockinfile = Some {
        marker = "# {mark} ansible / jbuild"
      , state = None Text
      , create = Some True
      , insertafter = Some "EOF"
      , path = "/home/{{ item }}/.ssh/config"
      , block = Some ''
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

      ''
      , insertbefore = None Text
    },
      loop = Some [ "{{ jbuild_users }}" ]
    }
  , Task::{
      name = Some "Create $HOME/bin directory",
      file = Some {
        path = Some "/home/{{ item }}/bin"
      , state = Some "directory"
      , mode = None Text
      , owner = Some "{{ item }}"
      , group = Some "{{ item }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      loop = Some [ "{{ jbuild_users }}" ]
    }
  , Task::{
      name = Some "Create wrappers for edctl",
      copy = Some {
        src = None Text
      , dest = "/home/{{ item }}/bin/edctl"
      , mode = Some "+x"
      , content = Some ''
        #!/bin/bash
        ssh edctl /opt/edctl/edctl.py "$@"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "{{ jbuild_users }}" ]
    }
  , Task::{
      name = Some "Create wrappers for jyctl",
      copy = Some {
        src = None Text
      , dest = "/home/{{ item }}/bin/jyctl"
      , mode = Some "+x"
      , content = Some ''
        #!/bin/bash
        ssh jyctl /opt/jyctl/jyctl.py "$@"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "{{ jbuild_users }}" ]
    }
  , Task::{
      name = Some "Login to registry",
      become = Some "True",
      become_user = Some "{{ item }}",
      `community.general.docker_login` = Some {
        registry_url = "{{ registry_domain }}"
      , username = "docker"
      , password = "{{ jbuild_registry_pass }}"
    },
      loop = Some [ "{{ jbuild_users }}" ]
    }
]
