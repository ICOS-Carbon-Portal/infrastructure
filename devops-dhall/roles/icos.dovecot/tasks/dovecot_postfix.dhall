-- Auto-generated from dovecot_postfix.yml

let Task =
    { Type =
        { name : Text
    , blockinfile : Optional ({ path : Text, create : Bool, insertbefore : Text, marker : Text, block : Text })
    , notify : Optional Text
    , copy : Optional ({ dest : Text, force : Bool, content : Text })
    , loop : Optional (List Text)
    , command : Optional Text
    , changed_when : Optional Bool
    , postconf : Optional ({ param : Text, value : Text, append : Text })
  }
    , default =
        { blockinfile = None ({ path : Text, create : Bool, insertbefore : Text, marker : Text, block : Text })
    , notify = None Text
    , copy = None ({ dest : Text, force : Bool, content : Text })
    , loop = None (List Text)
    , command = None Text
    , changed_when = None Bool
    , postconf = None ({ param : Text, value : Text, append : Text })
  }
    }

in  [
    Task::{
      name = "Create domains file",
      blockinfile = Some {
        path = "{{ dovecot_domains_file }}"
      , create = True
      , insertbefore = "BOF"
      , marker = "# {mark} ansible - icos.dovecot"
      , block = ''
        # These are used both for 'relay_domains' and for 'transport_maps'
        {% for domain in dovecot_domains %}
        {{ domain }}	lmtp:unix:private/{{ dovecot_lmtp | basename }}
        {% endfor %}

      ''
    },
      notify = Some "Reload postfix"
    }
  , Task::{
      name = "Make sure that postfix dbs exists",
      notify = Some "Reload postfix",
      copy = Some { dest = "{{ item }}", force = False, content = "" },
      loop = Some [ "/etc/postfix/transport", "/etc/postfix/virtual" ]
    }
  , Task::{
      name = "Compile postfix database files",
      loop = Some [
        "/etc/postfix/transport"
      , "/etc/postfix/virtual"
      , "{{ dovecot_domains_file }}"
    ],
      command = Some "postmap {{ item }}",
      changed_when = Some False
    }
  , Task::{
      name = "Configure postfix to use database files",
      loop = Some [
        { param = "virtual_alias_domains", value = "", append = Some False }
      , { param = "virtual_alias_maps", value = "hash:/etc/postfix/virtual", append = None Bool }
      , {
          param = "transport_maps",
          value = "hash:{{ dovecot_domains_file }}",
          append = None Bool
        }
      , { param = "relay_domains", value = "hash:{{ dovecot_domains_file }}", append = None Bool }
    ],
      postconf = Some {
        param = "{{ item.param }}"
      , value = "{{ item.value }}"
      , append = "{{ item.append | default(True) }}"
    }
    }
]
