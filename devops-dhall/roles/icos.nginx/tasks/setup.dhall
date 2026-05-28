-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , template : Optional ({ src : Text, dest : Text, owner : Text, group : Text, backup : Bool })
    , tags : Optional Text
    , notify : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , iptables_raw : Optional ({ name : Text, rules : Text })
    , service : Optional ({ name : Text, state : Text, enabled : Bool })
  }
    , default =
        { apt = None ({ name : List Text })
    , template = None ({ src : Text, dest : Text, owner : Text, group : Text, backup : Bool })
    , tags = None Text
    , notify = None Text
    , file = None ({ path : Text, state : Text })
    , iptables_raw = None ({ name : Text, rules : Text })
    , service = None ({ name : Text, state : Text, enabled : Bool })
  }
    }

in  [
    Task::{ name = "Install nginx", apt = Some { name = [ "nginx" ] } }
  , Task::{
      name = "Install nginx.conf",
      template = Some {
        src = "nginx.conf"
      , dest = "/etc/nginx/nginx.conf"
      , owner = "{{ nginx_user }}"
      , group = "{{ nginx_user }}"
      , backup = True
    },
      tags = Some "nginx_conf",
      notify = Some "reload nginx config"
    }
  , Task::{
      name = "Remove nginx default site",
      notify = Some "reload nginx config",
      file = Some { path = "/etc/nginx/sites-enabled/default", state = "absent" }
    }
  , Task::{
      name = "Allow nginx through firewall",
      iptables_raw = Some {
        name = "allow_nginx"
      , rules = ''
        -A INPUT -p tcp --dport 80 -j ACCEPT
        -A INPUT -p tcp --dport 443 -j ACCEPT

      ''
    }
    }
  , Task::{
      name = "Start nginx",
      service = Some { name = "nginx", state = "started", enabled = True }
    }
]
