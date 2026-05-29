-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add kubic key",
      `ansible.builtin.get_url` = Some {
        url = "https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_{{ ansible_lsb.release }}/Release.key"
      , dest = "/etc/apt/trusted.gpg.d/kubic.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = Some "Add kubic apt repository",
      apt_repository = Some {
        filename = Some "kubic"
      , repo = ''
        deb [signed-by={{ _key.dest }}] https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_{{ ansible_lsb.release }}/ /

      ''
    }
    }
  , Task::{
      name = Some "Install podman",
      apt = Some {
        name = Some [ "podman", "podman-plugins", "containernetworking-plugins" ]
      , state = None Text
      , update_cache = Some True
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
]
