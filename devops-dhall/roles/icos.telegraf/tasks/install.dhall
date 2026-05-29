-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add influxdata key",
      `ansible.builtin.get_url` = Some {
        url = "https://repos.influxdata.com/influxdata-archive_compat.key"
      , dest = "/etc/apt/trusted.gpg.d/influxdata.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = Some "Add influxdata apt repository",
      apt_repository = Some {
        filename = Some "influxdata"
      , repo = "deb [signed-by={{ _key.dest }}] https://repos.influxdata.com/debian stable main"
    }
    }
  , Task::{
      name = Some "Install telegraf",
      apt = Some {
        name = Some [ "telegraf" ]
      , state = Some "{{ 'latest' if telegraf_upgrade else 'present' }}"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = Some "{{ 3600 if telegraf_upgrade else omit}}"
      , install_recommends = None Bool
    },
      notify = Some [ "restart telegraf" ]
    }
]
