-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register : Optional Text
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , apt : Optional ({ update_cache : Bool, name : List Text })
  }
    , default =
        { `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register = None Text
    , apt_repository = None ({ filename : Text, repo : Text })
    , apt = None ({ update_cache : Bool, name : List Text })
  }
    }

in  [
    Task::{
      name = "Add kubic key",
      `ansible.builtin.get_url` = Some {
        url = "https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_{{ ansible_lsb.release }}/Release.key"
      , dest = "/etc/apt/trusted.gpg.d/kubic.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = "Add kubic apt repository",
      apt_repository = Some {
        filename = "kubic"
      , repo = ''
        deb [signed-by={{ _key.dest }}] https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_{{ ansible_lsb.release }}/ /

      ''
    }
    }
  , Task::{
      name = "Install podman",
      apt = Some {
        update_cache = True
      , name = [ "podman", "podman-plugins", "containernetworking-plugins" ]
    }
    }
]
