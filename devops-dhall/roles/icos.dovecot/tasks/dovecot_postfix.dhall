-- Auto-generated from ../../../../devops/roles/icos.dovecot/tasks/dovecot_postfix.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create domains file",
      blockinfile = Some {
        path = "{{ dovecot_domains_file }}",
        create = Some True,
        marker = "# {mark} ansible - icos.dovecot",
        block = Some ''
        # These are used both for 'relay_domains' and for 'transport_maps'
        {% for domain in dovecot_domains %}
        {{ domain }}	lmtp:unix:private/{{ dovecot_lmtp | basename }}
        {% endfor %}

      '',
        insertafter = None Text,
        insertbefore = Some "BOF",
        state = None Text
    },
      notify = Some [ "Reload postfix" ]
    }
  , Task::{
      name = Some "Make sure that postfix dbs exists",
      copy = Some {
        dest = "{{ item }}",
        mode = None Text,
        content = Some "",
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = Some "False",
        validate = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "/etc/postfix/transport", "/etc/postfix/virtual" ]),
      notify = Some [ "Reload postfix" ]
    }
  , Task::{
      name = Some "Compile postfix database files",
      command = Some "postmap {{ item }}",
      changed_when = Some (Task.Poly_changed_when.Bool False),
      loop = Some (Task.Poly_loop.Texts [
          "/etc/postfix/transport"
        , "/etc/postfix/virtual"
        , "{{ dovecot_domains_file }}"
      ])
    }
  , Task::{
      name = Some "Configure postfix to use database files",
      postconf = Some {
        param = "{{ item.param }}",
        value = "{{ item.value }}",
        reload = None Text,
        append = Some "{{ item.append | default(True) }}",
        separator = None Text
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = Some "",
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = Some "virtual_alias_domains",
            append = Some False,
            line = None Text,
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
            value = Some "hash:/etc/postfix/virtual",
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = Some "virtual_alias_maps",
            append = None Bool,
            line = None Text,
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
            value = Some "hash:{{ dovecot_domains_file }}",
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = Some "transport_maps",
            append = None Bool,
            line = None Text,
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
            value = Some "hash:{{ dovecot_domains_file }}",
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = Some "relay_domains",
            append = None Bool,
            line = None Text,
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
]
