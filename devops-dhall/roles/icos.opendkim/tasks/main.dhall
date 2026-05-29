-- Auto-generated from ../../../../devops/roles/icos.opendkim/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install opendkim",
      apt = Some {
        name = Some [ "opendkim", "opendkim-tools" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Create keys directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ opendkim_keys }}",
          state = Some "directory",
          owner = Some "{{ opendkim_user }}",
          group = Some "{{ opendkim_user }}",
          name = None Text,
          mode = Some "448",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Create opendkim.conf",
      template = Some {
        src = "opendkim.conf",
        dest = "/etc/opendkim.conf",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "Restart opendkim" ]
    }
  , Task::{
      name = Some "Create config files",
      template = Some {
        src = "{{ item }}",
        dest = "/etc/opendkim",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "signing.table", "key.table", "trusted.hosts" ]),
      notify = Some [ "Restart opendkim" ]
    }
  , Task::{
      name = Some "Create key directory for domain",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ opendkim_keys }}/{{ item }}",
          state = Some "directory",
          owner = Some "{{ opendkim_user }}",
          group = Some "{{ opendkim_user }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      loop = Some (Task.Poly_loop.Str "{{ opendkim_domains }}")
    }
  , Task::{
      name = Some "Create domain keys",
      become = Some (Task.Poly_become.Bool True),
      become_user = Some "{{ opendkim_user }}",
      command = Some "opendkim-genkey -b 2048 -d {{ item }} -s default -v && chmod 600 default.private",
      args = Some {
        chdir = Some "{{ opendkim_keys }}/{{ item }}",
        creates = Some "default.private",
        executable = None Text,
        removes = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ opendkim_domains }}")
    }
  , Task::{
      name = Some "Find domain keys that needs to be added to DNS",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str ''
        for d in {{ opendkim_domains | difference(opendkim_domains_testkeys) | join(" ") }}; do
          echo -n "default._domainkey $d ";
          cat {{ opendkim_keys }}/$d/default.txt | sed -n 'N;N;s/.*( //g;s/\x0A/ /g;s/).*//g;s/"[[:blank:]]*"//g;s/"//g;p';
        done
      ''),
      register = Some "_r",
      changed_when = Some (Task.Poly_changed_when.Bool False),
      when = Some [ "opendkim_domains | difference(opendkim_domains_testkeys)" ]
    }
  , Task::{
      name = Some "Print instructions about adding DNS records",
      debug = Some (Task.Poly_debug.Record {
          msg = ''
          Create the following DNS records:
          "{{ _r.stdout }}"

        ''
      }),
      when = Some [ "opendkim_domains | difference(opendkim_domains_testkeys)" ]
    }
  , Task::{
      name = Some "Run opendkim-testkey on keys that have been added to DNS",
      command = Some "opendkim-testkey -d {{ item }} -s default -vvv",
      changed_when = Some (Task.Poly_changed_when.Bool False),
      loop = Some (Task.Poly_loop.Str "{{ opendkim_domains_testkeys }}")
    }
  , Task::{
      name = Some "Create socket directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ opendkim_sock | dirname }}",
          state = Some "directory",
          owner = Some "opendkim",
          group = Some "postfix",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Configure postfix",
      postconf = Some {
        param = "{{ item.param }}",
        value = "{{ item.value }}",
        reload = None Text,
        append = Some "{{ item.append | default(omit) }}",
        separator = None Text
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = Some "local:opendkim/opendkim.sock",
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = Some "smtpd_milters",
            append = Some True,
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
            value = Some "$smtpd_milters",
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = Some "non_smtpd_milters",
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
      ]),
      notify = Some [ "Restart postfix" ]
    }
  , Task::{
      name = Some "Add postfix to the opendkim group",
      user = Some {
        name = "postfix",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = None Text,
        home = None Text,
        password_lock = None Bool,
        groups = Some [ "opendkim" ],
        append = Some "True",
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    },
      notify = Some [ "Restart postfix" ]
    }
]
