-- Auto-generated from dovecot_listen.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Change listening port",
      lineinfile = Some {
        path = "/etc/dovecot/conf.d/10-master.conf"
      , line = Some "    port = {{ dovecot_port }}"
      , state = Some "present"
      , regex = Some "(?:#port = 993$)|(?:^    port = {{ dovecot_port }}$)"
      , regexp = None Text
      , create = None Bool
      , owner = None Text
      , group = None Text
      , insertafter = None Text
      , mode = None Natural
      , insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Allow dovecot through firewall",
      iptables_raw = Some {
        name = "allow_dovecot"
      , rules = Some "-A INPUT -p tcp --dport {{ dovecot_port }} -j ACCEPT -m comment --comment 'dovecot'"
      , weight = None Natural
      , table = None Text
      , state = None Text
    }
    }
  , Task::{
      name = Some "Add postfix lmtp listener",
      blockinfile = Some {
        marker = "# {mark} ansible / icos.dovecot / postfix lmtp"
      , state = None Text
      , create = None Bool
      , insertafter = Some "^service lmtp {"
      , path = "/etc/dovecot/conf.d/10-master.conf"
      , block = Some ''
          unix_listener {{ dovecot_lmtp }} {
            user = postfix
            group = postfix
          }

      ''
      , insertbefore = None Text
    }
    }
]
