-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register : Optional Text
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , apt : Optional ({ name : Text, state : Text, cache_valid_time : Text })
    , notify : Optional Text
  }
    , default =
        { `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register = None Text
    , apt_repository = None ({ filename : Text, repo : Text })
    , apt = None ({ name : Text, state : Text, cache_valid_time : Text })
    , notify = None Text
  }
    }

in  [
    Task::{
      name = "Add influxdata key",
      `ansible.builtin.get_url` = Some {
        url = "https://repos.influxdata.com/influxdata-archive_compat.key"
      , dest = "/etc/apt/trusted.gpg.d/influxdata.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = "Add influxdata apt repository",
      apt_repository = Some {
        filename = "influxdata"
      , repo = "deb [signed-by={{ _key.dest }}] https://repos.influxdata.com/debian stable main"
    }
    }
  , Task::{
      name = "Install telegraf",
      apt = Some {
        name = "telegraf"
      , state = "{{ 'latest' if telegraf_upgrade else 'present' }}"
      , cache_valid_time = "{{ 3600 if telegraf_upgrade else omit}}"
    },
      notify = Some "restart telegraf"
    }
]
