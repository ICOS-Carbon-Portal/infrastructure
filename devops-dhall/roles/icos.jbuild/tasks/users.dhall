-- Auto-generated from users.yml

let Task =
    { Type =
        { name : Text
    , openssh_keypair : Optional ({ path : Text, owner : Text, group : Text })
    , loop : Text
    , register : Optional Text
    , blockinfile : Optional ({ path : Text, marker : Text, create : Bool, insertafter : Text, block : Text })
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text })
    , copy : Optional ({ dest : Text, mode : Text, content : Text })
    , become : Optional Bool
    , become_user : Optional Text
    , `community.general.docker_login` : Optional ({ registry_url : Text, username : Text, password : Text })
  }
    , default =
        { openssh_keypair = None ({ path : Text, owner : Text, group : Text })
    , register = None Text
    , blockinfile = None ({ path : Text, marker : Text, create : Bool, insertafter : Text, block : Text })
    , file = None ({ path : Text, state : Text, owner : Text, group : Text })
    , copy = None ({ dest : Text, mode : Text, content : Text })
    , become = None Bool
    , become_user = None Text
    , `community.general.docker_login` = None ({ registry_url : Text, username : Text, password : Text })
  }
    }

in  [
    Task::{
      name = "Generate keys for jbuild",
      openssh_keypair = Some {
        path = "/home/{{ item }}/.ssh/jbuild"
      , owner = "{{ item }}"
      , group = "{{ item }}"
    },
      loop = "{{ jbuild_users }}",
      register = Some "_jbuild_user_keys"
    }
  , Task::{
      name = "Generate jbuild ssh config",
      loop = "{{ jbuild_users }}",
      blockinfile = Some {
        path = "/home/{{ item }}/.ssh/config"
      , marker = "# {mark} ansible / jbuild"
      , create = True
      , insertafter = "EOF"
      , block = ''
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
    }
    }
  , Task::{
      name = "Create $HOME/bin directory",
      loop = "{{ jbuild_users }}",
      file = Some {
        path = "/home/{{ item }}/bin"
      , state = "directory"
      , owner = "{{ item }}"
      , group = "{{ item }}"
    }
    }
  , Task::{
      name = "Create wrappers for edctl",
      loop = "{{ jbuild_users }}",
      copy = Some {
        dest = "/home/{{ item }}/bin/edctl"
      , mode = "+x"
      , content = ''
        #!/bin/bash
        ssh edctl /opt/edctl/edctl.py "$@"

      ''
    }
    }
  , Task::{
      name = "Create wrappers for jyctl",
      loop = "{{ jbuild_users }}",
      copy = Some {
        dest = "/home/{{ item }}/bin/jyctl"
      , mode = "+x"
      , content = ''
        #!/bin/bash
        ssh jyctl /opt/jyctl/jyctl.py "$@"

      ''
    }
    }
  , Task::{
      name = "Login to registry",
      loop = "{{ jbuild_users }}",
      become = Some True,
      become_user = Some "{{ item }}",
      `community.general.docker_login` = Some {
        registry_url = "{{ registry_domain }}"
      , username = "docker"
      , password = "{{ jbuild_registry_pass }}"
    }
    }
]
