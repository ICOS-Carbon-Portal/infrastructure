-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install nginx",
      apt = Some {
        name = Some [ "nginx" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Install nginx.conf",
      template = Some {
        src = "nginx.conf"
      , dest = "/etc/nginx/nginx.conf"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = Some True
      , owner = Some "{{ nginx_user }}"
      , group = Some "{{ nginx_user }}"
    },
      tags = Some [ "nginx_conf" ],
      notify = Some [ "reload nginx config" ]
    }
  , Task::{
      name = Some "Remove nginx default site",
      file = Some {
        path = Some "/etc/nginx/sites-enabled/default"
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      notify = Some [ "reload nginx config" ]
    }
  , Task::{
      name = Some "Allow nginx through firewall",
      iptables_raw = Some {
        name = "allow_nginx"
      , rules = Some ''
        -A INPUT -p tcp --dport 80 -j ACCEPT
        -A INPUT -p tcp --dport 443 -j ACCEPT

      ''
      , weight = None Natural
      , table = None Text
      , state = None Text
    }
    }
  , Task::{
      name = Some "Start nginx",
      service = Some { name = "nginx", state = "started", enabled = Some True }
    }
]
