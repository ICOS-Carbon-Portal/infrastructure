-- Auto-generated from mail-rspamd.yml

let Play =
    { Type =
        { hosts : Text
    , vars : { rspamd_domain : Optional Text, rspamd_user_file : Optional Text, rspamd_admin_password : Optional Text, rspamd_admin_password_hashed : Optional Text }
    , pre_tasks : Optional (List ({ name : Text, tags : Optional Text, shell : Optional Text, register : Text, changed_when : Optional (List Text), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, type : Text, pool : Text, size : Text } }, wait_for_ipv4_addresses : Bool, timeout : Natural }) }))
    , roles : List ({ role : Text, lxd_forward_ip : Optional Text, lxd_forward_name : Optional Text, tags : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_users : Optional (List ({ username : Text, password : Text })) })
    , tasks : Optional (List ({ name : Text, tags : Text, postconf : { param : Text, value : Text, reload : Bool, append : Bool } }))
  }
    , default =
        { pre_tasks = None (List ({ name : Text, tags : Optional Text, shell : Optional Text, register : Text, changed_when : Optional (List Text), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, type : Text, pool : Text, size : Text } }, wait_for_ipv4_addresses : Bool, timeout : Natural }) }))
    , tasks = None (List ({ name : Text, tags : Text, postconf : { param : Text, value : Text, reload : Bool, append : Bool } }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      vars = {
        rspamd_domain = Some "rspamd.icos-cp.eu"
      , rspamd_user_file = Some "/etc/nginx/auth/rspamd"
      , rspamd_admin_password = Some "{{ vault_rspamd_admin_password }}"
      , rspamd_admin_password_hashed = None Text
    },
      pre_tasks = Some [
        {
          name = "Create rspamd storage pool",
          tags = Some "pool",
          shell = Some "/snap/bin/lxc storage show rspamd > /dev/null 2>&1 || /snap/bin/lxc storage create rspamd btrfs size=50GB",
          register = "_r",
          changed_when = Some [ "\"Storage pool rspamd created\" in _r.stdout" ],
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, type : Text, pool : Text, size : Text } }, wait_for_ipv4_addresses : Bool, timeout : Natural })
        }
      , {
          name = "Create the rspamd container",
          tags = None Text,
          shell = None Text,
          register = "_lxd",
          changed_when = None (List Text),
          lxd_container = Some {
            name = "rspamd"
          , state = "started"
          , profiles = [ "default", "ssh_root" ]
          , source = {
              type = "image"
            , mode = "pull"
            , server = "https://cloud-images.ubuntu.com/releases"
            , protocol = "simplestreams"
            , alias = "22.04"
          }
          , devices = {
              root = {
                path = "/"
              , type = "disk"
              , pool = "rspamd"
              , size = "50GB"
            }
          }
          , wait_for_ipv4_addresses = True
          , timeout = 600
        }
        }
    ],
      roles = [
        {
          role = "icos.lxd_forward",
          lxd_forward_ip = Some "{{ _lxd.addresses.eth0 | first }}",
          lxd_forward_name = Some "rspamd",
          tags = None Text,
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          nginxsite_users = None (List ({ username : Text, password : Text }))
        }
      , {
          role = "icos.certbot2",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "cert",
          certbot_name = Some "rspamd",
          certbot_domains = Some [ "{{ rspamd_domain }}" ],
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          nginxsite_users = None (List ({ username : Text, password : Text }))
        }
      , {
          role = "icos.nginxsite",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "nginx",
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = Some "rspamd",
          nginxsite_file = Some "files/rspamd.conf",
          nginxsite_users = Some [
            { username = "secret", password = "{{ rspamd_admin_password }}" }
        ]
        }
    ],
      tasks = Some [
        {
          name = "Configure postfix to use rspamd as a milter"
        , tags = "postconf"
        , postconf = {
            param = "smtpd_milters"
          , value = "inet:rspamd.lxd:11332"
          , reload = True
          , append = True
        }
      }
    ]
    }
  , Play::{
      hosts = "rspamd",
      vars = {
        rspamd_domain = None Text
      , rspamd_user_file = None Text
      , rspamd_admin_password = None Text
      , rspamd_admin_password_hashed = Some "{{ vault_rspamd_admin_password_hashed }}"
    },
      roles = [
        {
          role = "icos.lxd_guest",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "guest",
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          nginxsite_users = None (List ({ username : Text, password : Text }))
        }
      , {
          role = "icos.rspamd",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "rspamd",
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          nginxsite_users = None (List ({ username : Text, password : Text }))
        }
    ]
    }
]
