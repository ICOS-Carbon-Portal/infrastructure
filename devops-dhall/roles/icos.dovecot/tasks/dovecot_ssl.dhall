-- Auto-generated from ../../../../devops/roles/icos.dovecot/tasks/dovecot_ssl.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy {{ dovecot_cert_file }}",
      template = Some {
        src = "{{ dovecot_cert_file }}",
        dest = "/etc/dovecot/conf.d/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Configure dovecot ssl",
      lineinfile = Some {
        path = "/etc/dovecot/conf.d/10-ssl.conf",
        regex = Some "{{ item.regex | default(omit) }}",
        line = Some "{{ item.line }}",
        state = Some "present",
        backrefs = None Bool,
        regexp = None Text,
        create = None Bool,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = Some "ssl = required",
            regex = Some "(?:ssl = yes)|(?:ssl = required)",
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = Some "ssl_dh = </usr/share/dovecot/dh.pem",
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = Some "ssl_protocols = TLSv1.2 TLSv1.1 TLSv1 !SSLv3 !SSLv2",
            regex = Some "^#?\\s*ssl_protocols.*",
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = Some "!include {{ dovecot_cert_file }}",
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
      ])
    }
  , Task::{
      name = Some "Add a dovecot deploy-hook for certbot",
      copy = Some {
        dest = "/etc/letsencrypt/renewal-hooks/deploy/dovecot.sh",
        mode = Some "+x",
        content = Some ''
        #!/bin/bash
        service dovecot reload

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
