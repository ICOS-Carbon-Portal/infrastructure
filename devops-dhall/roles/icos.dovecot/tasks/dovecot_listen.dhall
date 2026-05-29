-- Auto-generated from ../../../../devops/roles/icos.dovecot/tasks/dovecot_listen.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Change listening port",
      lineinfile = Some {
        path = "/etc/dovecot/conf.d/10-master.conf",
        regex = Some "(?:#port = 993$)|(?:^    port = {{ dovecot_port }}$)",
        line = Some "    port = {{ dovecot_port }}",
        state = Some "present",
        backrefs = None Bool,
        regexp = None Text,
        create = None Bool,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Allow dovecot through firewall",
      iptables_raw = Some {
        name = "allow_dovecot",
        rules = Some "-A INPUT -p tcp --dport {{ dovecot_port }} -j ACCEPT -m comment --comment 'dovecot'",
        table = None Text,
        state = None Text,
        weight = None Natural
    }
    }
  , Task::{
      name = Some "Add postfix lmtp listener",
      blockinfile = Some {
        path = "/etc/dovecot/conf.d/10-master.conf",
        create = None Bool,
        marker = "# {mark} ansible / icos.dovecot / postfix lmtp",
        block = Some ''
          unix_listener {{ dovecot_lmtp }} {
            user = postfix
            group = postfix
          }

      '',
        insertafter = Some "^service lmtp {",
        insertbefore = None Text,
        state = None Text
    }
    }
]
