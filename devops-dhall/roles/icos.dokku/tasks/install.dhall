-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register : Optional Text
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , `ansible.builtin.debconf` : Optional ({ name : Text, question : Text, value : Text, vtype : Text })
    , loop : Optional (List ({ question : Text, value : Text, vtype : Text }))
    , apt : Optional ({ name : List Text })
  }
    , default =
        { `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register = None Text
    , apt_repository = None ({ filename : Text, repo : Text })
    , `ansible.builtin.debconf` = None ({ name : Text, question : Text, value : Text, vtype : Text })
    , loop = None (List ({ question : Text, value : Text, vtype : Text }))
    , apt = None ({ name : List Text })
  }
    }

in  [
    Task::{
      name = "Add dokku key",
      `ansible.builtin.get_url` = Some {
        url = "https://packagecloud.io/dokku/dokku/gpgkey"
      , dest = "/etc/apt/trusted.gpg.d/dokku.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = "Add dokku apt repository",
      apt_repository = Some {
        filename = "dokku"
      , repo = "deb [signed-by={{ _key.dest }}] https://packagecloud.io/dokku/dokku/{{ ansible_lsb.id | lower }}/ {{ ansible_lsb.codename }} main"
    }
    }
  , Task::{
      name = "Set debconf values for dokku",
      `ansible.builtin.debconf` = Some {
        name = "dokku"
      , question = "{{ item.question }}"
      , value = "{{ item.value }}"
      , vtype = "{{ item.vtype }}"
    },
      loop = Some [
        { question = "dokku/vhost_enable", value = "true", vtype = "boolean" }
      , {
          question = "dokku/hostname"
        , value = "dokku.fsicos3.icos-cp.eu"
        , vtype = "string"
      }
      , { question = "dokku/nginx_enable", value = "true", vtype = "boolean" }
    ]
    }
  , Task::{ name = "Install dokku", apt = Some { name = [ "dokku" ] } }
]
