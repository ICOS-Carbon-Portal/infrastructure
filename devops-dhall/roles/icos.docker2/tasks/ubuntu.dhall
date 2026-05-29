-- Auto-generated from ../../../../devops/roles/icos.docker2/tasks/ubuntu.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add docker key",
      `ansible.builtin.get_url` = Some {
        url = "https://download.docker.com/linux/ubuntu/gpg",
        dest = "/etc/apt/trusted.gpg.d/docker.asc",
        mode = "0644",
        force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = Some "Retrieve deb_arch fact",
      shellfact = Some {
        exec = "dpkg --print-architecture",
        fact = "deb_arch",
        bool = None Bool,
        list = None Bool
    },
      check_mode = Some False
    }
  , Task::{
      name = Some "Add docker apt repository",
      apt_repository = Some {
        filename = Some "docker",
        repo = "deb [arch={{ deb_arch }} signed-by={{ _key.dest }}] https://download.docker.com/linux/ubuntu {{ ansible_lsb.codename }} stable"
    }
    }
]
