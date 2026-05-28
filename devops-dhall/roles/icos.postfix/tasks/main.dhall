-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text, state : Text })
    , service : Optional ({ name : Text, state : Text, enabled : Bool })
    , postconf : Optional ({ param : Text, value : Text, append : Text, reload : Text, separator : Text })
    , loop : Optional Text
    , iptables_raw : Optional ({ name : Text, rules : Text })
    , tags : Optional Text
    , include_role : Optional ({ name : Text, apply : { tags : Text } })
    , vars : Optional ({ fail2ban_config_files : List ({ dest : Text, content : Text }) })
  }
    , default =
        { apt = None ({ name : Text, state : Text })
    , service = None ({ name : Text, state : Text, enabled : Bool })
    , postconf = None ({ param : Text, value : Text, append : Text, reload : Text, separator : Text })
    , loop = None Text
    , iptables_raw = None ({ name : Text, rules : Text })
    , tags = None Text
    , include_role = None ({ name : Text, apply : { tags : Text } })
    , vars = None ({ fail2ban_config_files : List ({ dest : Text, content : Text }) })
  }
    }

in  [
    Task::{ name = "Install postfix", apt = Some { name = "postfix", state = "present" } }
  , Task::{
      name = "Start and enable postfix",
      service = Some { name = "postfix", state = "started", enabled = True }
    }
  , Task::{
      name = "Set configuration parameters",
      postconf = Some {
        param = "{{ item.param }}"
      , value = "{{ item.value }}"
      , append = "{{ item.append | default(omit) }}"
      , reload = "{{ item.reload | default(omit) }}"
      , separator = "{{ item.separator | default(omit) }}"
    },
      loop = Some "{{ postfix_config_list }}"
    }
  , Task::{
      name = "Allow SMTP through firewall",
      iptables_raw = Some {
        name = "allow_SMTP"
      , rules = "-A INPUT -p tcp --dport 25 -j ACCEPT -m comment --comment 'smtp'"
    }
    }
  , Task::{
      name = "Install fail2ban",
      tags = Some "postfix_fail2ban",
      include_role = Some { name = "icos.fail2ban", apply = { tags = "postfix_fail2ban" } },
      vars = Some {
        fail2ban_config_files = [
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
    }
    }
]
