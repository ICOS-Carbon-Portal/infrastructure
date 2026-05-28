-- Auto-generated from dovecot_listen.yml

let Entry =
    { Type =
        { name : Text
    , lineinfile : Optional ({ path : Text, regex : Text, line : Text, state : Text })
    , iptables_raw : Optional ({ name : Text, rules : Text })
    , blockinfile : Optional ({ path : Text, marker : Text, insertafter : Text, block : Text })
  }
    , default =
        { lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text })
    , iptables_raw = None ({ name : Text, rules : Text })
    , blockinfile = None ({ path : Text, marker : Text, insertafter : Text, block : Text })
  }
    }

in  [
    Entry::{
      name = "Change listening port",
      lineinfile = Some {
        path = "/etc/dovecot/conf.d/10-master.conf"
      , regex = "(?:#port = 993$)|(?:^    port = {{ dovecot_port }}$)"
      , line = "    port = {{ dovecot_port }}"
      , state = "present"
    }
    }
  , Entry::{
      name = "Allow dovecot through firewall",
      iptables_raw = Some {
        name = "allow_dovecot"
      , rules = "-A INPUT -p tcp --dport {{ dovecot_port }} -j ACCEPT -m comment --comment 'dovecot'"
    }
    }
  , Entry::{
      name = "Add postfix lmtp listener",
      blockinfile = Some {
        path = "/etc/dovecot/conf.d/10-master.conf"
      , marker = "# {mark} ansible / icos.dovecot / postfix lmtp"
      , insertafter = "^service lmtp {"
      , block = ''
          unix_listener {{ dovecot_lmtp }} {
            user = postfix
            group = postfix
          }

      ''
    }
    }
]
