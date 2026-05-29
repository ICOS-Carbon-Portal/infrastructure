-- Auto-generated from ../../../../devops/roles/icos.sftp_user/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some (Task.Poly_loop.Texts [ "sftp_user_dir", "sftp_user_login" ])
    }
  , Task::{
      name = Some "Check whether sftp parent directory exists",
      stat = Some { path = "{{ _sftp_parent_dir }}" },
      check_mode = Some False,
      register = Some "_parent"
    }
  , Task::{
      name = Some "Create sftp parent directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ _sftp_parent_dir }}",
          state = Some "directory",
          owner = Some "root",
          group = Some "root",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      when = Some [ "not _parent.stat.exists" ]
    }
  , Task::{
      name = Some "Create sftp user",
      user = Some {
        name = "{{ sftp_user_login }}",
        uid = None Text,
        group = None Text,
        password = Some ''
        {{ sftp_user_password | password_hash('sha512', vault_pw_salt)
           if sftp_user_password else omit }}
      '',
        non_unique = None Bool,
        create_home = Some "{{ sftp_user_pubkey is truthy }}",
        shell = Some "/usr/sbin/nologin",
        home = None Text,
        password_lock = None Bool,
        groups = None ((List Text)),
        append = None Text,
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    },
      register = Some "_user"
    }
  , Task::{
      name = Some "Install public key",
      authorized_key = Some {
        user = "{{ sftp_user_login }}",
        key = "{{ sftp_user_pubkey }}",
        state = None Text,
        exclusive = None Bool,
        key_options = None Text
    },
      when = Some [ "sftp_user_pubkey" ]
    }
  , Task::{
      name = Some "Stat parent directory again",
      stat = Some { path = "{{ _sftp_parent_dir }}" },
      check_mode = Some False,
      register = Some "_parent"
    }
  , Task::{
      name = Some "Fail if parent directory isn't owned by root",
      fail = Some { msg = "{{ _sftp_parent_dir }} must be owned by root" },
      when = Some [ "_parent.stat.uid != 0 or _parent.stat.gid != 0" ]
    }
  , Task::{
      name = Some "Create sftp directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ sftp_user_dir }}",
          state = Some "directory",
          owner = Some "{{ sftp_user_owner }}",
          group = Some "{{ sftp_user_group }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Add sftp user config to sshd to sshd_config",
      blockinfile = Some {
        path = "/etc/ssh/sshd_config",
        create = Some True,
        marker = "# {mark} ansible / sftp_user / {{ sftp_user_login }}",
        block = Some ''
        Match User {{ sftp_user_login }}
          ChrootDirectory {{ _sftp_parent_dir }}
          ForceCommand internal-sftp -d {{ sftp_user_dir | basename }}
          DisableForwarding yes
          PasswordAuthentication yes

      '',
        insertafter = Some "EOF",
        insertbefore = None Text,
        state = None Text
    },
      notify = Some [ "reload sshd" ]
    }
  , Task::{
      name = Some "Print ssh config",
      debug = Some (Task.Poly_debug.Record {
          msg = ''
          # {{ sftp_user_password}}
          Host {{ sftp_user_hostdesc }}
            HostName {{ ansible_host }}
            Port {{ ansible_port }}
            User {{ sftp_user_login }}
            {% if sftp_user_password %}
            PreferredAuthentications password
            {%- endif %}

        ''
      })
    }
]
