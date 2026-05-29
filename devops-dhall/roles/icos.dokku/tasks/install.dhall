-- Auto-generated from ../../../../devops/roles/icos.dokku/tasks/install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add dokku key",
      `ansible.builtin.get_url` = Some {
        url = "https://packagecloud.io/dokku/dokku/gpgkey",
        dest = "/etc/apt/trusted.gpg.d/dokku.asc",
        mode = "0644",
        force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = Some "Add dokku apt repository",
      apt_repository = Some {
        filename = Some "dokku",
        repo = "deb [signed-by={{ _key.dest }}] https://packagecloud.io/dokku/dokku/{{ ansible_lsb.id | lower }}/ {{ ansible_lsb.codename }} main"
    }
    }
  , Task::{
      name = Some "Set debconf values for dokku",
      `ansible.builtin.debconf` = Some {
        name = "dokku",
        question = "{{ item.question }}",
        value = "{{ item.value }}",
        vtype = "{{ item.vtype }}"
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = Some "dokku/vhost_enable",
            value = Some "true",
            vtype = Some "boolean",
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = Some "dokku/hostname",
            value = Some "dokku.fsicos3.icos-cp.eu",
            vtype = Some "string",
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = Some "dokku/nginx_enable",
            value = Some "true",
            vtype = Some "boolean",
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
      ])
    }
  , Task::{
      name = Some "Install dokku",
      apt = Some {
        name = Some [ "dokku" ],
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
]
