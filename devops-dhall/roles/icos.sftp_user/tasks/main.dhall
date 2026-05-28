-- Auto-generated from main.yml

let Item =
    { Type =
        { fail : Optional ({ msg : Text })
    , when : Optional Text
    , loop : Optional (List Text)
    , name : Optional Text
    , stat : Optional ({ path : Text })
    , check_mode : Optional Bool
    , register : Optional Text
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text })
    , user : Optional ({ name : Text, password : Text, create_home : Text, shell : Text })
    , authorized_key : Optional ({ user : Text, key : Text })
    , blockinfile : Optional ({ marker : Text, create : Bool, insertafter : Text, path : Text, block : Text })
    , notify : Optional Text
    , debug : Optional ({ msg : Text })
  }
    , default =
        { fail = None ({ msg : Text })
    , when = None Text
    , loop = None (List Text)
    , name = None Text
    , stat = None ({ path : Text })
    , check_mode = None Bool
    , register = None Text
    , file = None ({ path : Text, state : Text, owner : Text, group : Text })
    , user = None ({ name : Text, password : Text, create_home : Text, shell : Text })
    , authorized_key = None ({ user : Text, key : Text })
    , blockinfile = None ({ marker : Text, create : Bool, insertafter : Text, path : Text, block : Text })
    , notify = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [ "sftp_user_dir", "sftp_user_login" ]
    }
  , Item::{
      name = Some "Check whether sftp parent directory exists",
      stat = Some { path = "{{ _sftp_parent_dir }}" },
      check_mode = Some False,
      register = Some "_parent"
    }
  , Item::{
      when = Some "not _parent.stat.exists",
      name = Some "Create sftp parent directory",
      file = Some {
        path = "{{ _sftp_parent_dir }}"
      , state = "directory"
      , owner = "root"
      , group = "root"
    }
    }
  , Item::{
      name = Some "Create sftp user",
      register = Some "_user",
      user = Some {
        name = "{{ sftp_user_login }}"
      , password = ''
        {{ sftp_user_password | password_hash('sha512', vault_pw_salt)
           if sftp_user_password else omit }}
      ''
      , create_home = "{{ sftp_user_pubkey is truthy }}"
      , shell = "/usr/sbin/nologin"
    }
    }
  , Item::{
      when = Some "sftp_user_pubkey",
      name = Some "Install public key",
      authorized_key = Some { user = "{{ sftp_user_login }}", key = "{{ sftp_user_pubkey }}" }
    }
  , Item::{
      name = Some "Stat parent directory again",
      stat = Some { path = "{{ _sftp_parent_dir }}" },
      check_mode = Some False,
      register = Some "_parent"
    }
  , Item::{
      fail = Some { msg = "{{ _sftp_parent_dir }} must be owned by root" },
      when = Some "_parent.stat.uid != 0 or _parent.stat.gid != 0",
      name = Some "Fail if parent directory isn't owned by root"
    }
  , Item::{
      name = Some "Create sftp directory",
      file = Some {
        path = "{{ sftp_user_dir }}"
      , state = "directory"
      , owner = "{{ sftp_user_owner }}"
      , group = "{{ sftp_user_group }}"
    }
    }
  , Item::{
      name = Some "Add sftp user config to sshd to sshd_config",
      blockinfile = Some {
        marker = "# {mark} ansible / sftp_user / {{ sftp_user_login }}"
      , create = True
      , insertafter = "EOF"
      , path = "/etc/ssh/sshd_config"
      , block = ''
        Match User {{ sftp_user_login }}
          ChrootDirectory {{ _sftp_parent_dir }}
          ForceCommand internal-sftp -d {{ sftp_user_dir | basename }}
          DisableForwarding yes
          PasswordAuthentication yes

      ''
    },
      notify = Some "reload sshd"
    }
  , Item::{
      name = Some "Print ssh config",
      debug = Some {
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
    }
    }
]
