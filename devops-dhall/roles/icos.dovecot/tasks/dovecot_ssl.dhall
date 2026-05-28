-- Auto-generated from dovecot_ssl.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text })
    , lineinfile : Optional ({ path : Text, state : Text, regex : Text, line : Text })
    , loop : Optional (List ({ line : Text, regex : Optional Text }))
    , copy : Optional ({ dest : Text, mode : Text, content : Text })
  }
    , default =
        { template = None ({ src : Text, dest : Text })
    , lineinfile = None ({ path : Text, state : Text, regex : Text, line : Text })
    , loop = None (List ({ line : Text, regex : Optional Text }))
    , copy = None ({ dest : Text, mode : Text, content : Text })
  }
    }

in  [
    Task::{
      name = "Copy {{ dovecot_cert_file }}",
      template = Some { src = "{{ dovecot_cert_file }}", dest = "/etc/dovecot/conf.d/" }
    }
  , Task::{
      name = "Configure dovecot ssl",
      lineinfile = Some {
        path = "/etc/dovecot/conf.d/10-ssl.conf"
      , state = "present"
      , regex = "{{ item.regex | default(omit) }}"
      , line = "{{ item.line }}"
    },
      loop = Some [
        { line = "ssl = required", regex = Some "(?:ssl = yes)|(?:ssl = required)" }
      , { line = "ssl_dh = </usr/share/dovecot/dh.pem", regex = None Text }
      , {
          line = "ssl_protocols = TLSv1.2 TLSv1.1 TLSv1 !SSLv3 !SSLv2",
          regex = Some "^#?\\s*ssl_protocols.*"
        }
      , { line = "!include {{ dovecot_cert_file }}", regex = None Text }
    ]
    }
  , Task::{
      name = "Add a dovecot deploy-hook for certbot",
      copy = Some {
        dest = "/etc/letsencrypt/renewal-hooks/deploy/dovecot.sh"
      , mode = "+x"
      , content = ''
        #!/bin/bash
        service dovecot reload

      ''
    }
    }
]
