-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install postfix",
      apt = Some {
        name = Some [ "postfix" ]
      , state = Some "present"
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
      name = Some "Start and enable postfix",
      service = Some { name = "postfix", state = "started", enabled = Some True }
    }
  , Task::{
      name = Some "Set configuration parameters",
      postconf = Some {
        param = "{{ item.param }}"
      , value = "{{ item.value }}"
      , append = "{{ item.append | default(omit) }}"
      , reload = Some "{{ item.reload | default(omit) }}"
      , separator = Some "{{ item.separator | default(omit) }}"
    },
      loop = Some [ "{{ postfix_config_list }}" ]
    }
  , Task::{
      name = Some "Allow SMTP through firewall",
      iptables_raw = Some {
        name = "allow_SMTP"
      , rules = Some "-A INPUT -p tcp --dport 25 -j ACCEPT -m comment --comment 'smtp'"
      , weight = None Natural
      , table = None Text
      , state = None Text
    }
    }
  , Task::{
      name = Some "Install fail2ban",
      tags = Some [ "postfix_fail2ban" ],
      include_role = Some {
        name = "icos.fail2ban"
      , apply = Some { tags = "postfix_fail2ban" }
      , public = None Bool
      , tasks_from = None Text
    },
      vars = Some {
        timer_home = None Text
      , timer_exec = None Text
      , timer_name = None Text
      , timer_conf = None Text
      , timer_envs = None (List Text)
      , timer_content = None Text
      , timer_user = None Text
      , block = None Text
      , marker = None Text
      , where = None Text
      , state = None Text
      , bbclient_name = None Text
      , bbclient_user = None Text
      , bbclient_home = None Text
      , bbclient_timer_conf = None Text
      , bbclient_timer_content = None Text
      , certbot_name = None Text
      , certbot_domains = None (List Text)
      , nginxsite_name = None Text
      , nginxsite_file = None Text
      , _restart_needed = None Text
      , fail2ban_config_files = Some [
          {
            dest = "/etc/fail2ban/jail.d/postfix.local"
          , content = ''
            [postfix]
            enabled = true
            mode = aggressive

          ''
        }
        , {
            dest = "/etc/fail2ban/filter.d/postfix-auth.local"
          , content = ''
            [Definition]
            # Stop stupid bots from filling logs.
            failregex = lost connection after AUTH from unknown\[<HOST>\]$

          ''
        }
        , {
            dest = "/etc/fail2ban/jail.d/postfix-auth.local"
          , content = ''
            [postfix-auth]
            enabled = true
            port    = smtp
            filter  = postfix-auth
            logpath = /var/log/mail.log
            maxretry = 1
            bantime  = 1h

          ''
        }
      ]
      , nginxauth_file = None Text
      , nginxauth_users = None Text
      , jarservice_name = None Text
      , jarservice_home = None Text
      , jarservice_local = None Text
      , jarservice_unit = None Text
      , nginxsite_domains = None (List Text)
      , jupyter_cert_name = None Text
      , conf = None Text
      , lxd_forward_name = None Text
      , lxd_forward_ip = None Text
      , lxd_forward_port = None Text
      , file = None Text
      , keys = None Text
      , zfsdocker_size = None Text
      , set_fact = None Text
      , file_var = None Text
      , python_util_src = None Text
      , nginxauth_name = None Text
      , dbin_download_dest = None Text
      , dbin_user = None Text
      , dbin_repo = None Text
      , dbin_path = None Text
      , dbin_arch = None Text
      , timer_wdir = None Text
      , vmagent_config_dest = None Text
      , vmagent_config_content = None Text
      , dbin_src = None Text
      , dbin_url = None Text
      , _builtin_version = None Text
      , nginxauth_conf = None Text
      , nginxsite_users = None (List Text)
      , dbin_unar = None Bool
      , timer_state = None Text
      , timer_config = None Text
      , timer_service = None Text
    }
    }
]
