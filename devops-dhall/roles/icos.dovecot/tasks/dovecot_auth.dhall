-- Auto-generated from dovecot_auth.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create dovecot vmail user",
      user = Some {
        name = "{{ dovecot_vmail_name }}"
      , home = Some "{{ dovecot_vmail_home }}"
      , create_home = Some "True"
      , shell = Some "/usr/sbin/nologin"
      , groups = None (List Text)
      , append = None Text
      , state = None Text
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    },
      register = Some "dovecot_vmail_user"
    }
  , Task::{
      name = Some "Copy {{ dovecot_auth_file }}",
      template = Some {
        src = "{{ dovecot_auth_file }}"
      , dest = "/etc/dovecot/conf.d"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    }
    }
  , Task::{
      name = Some "Add passwd-file authentication to dovecot",
      lineinfile = Some {
        path = "/etc/dovecot/conf.d/10-auth.conf"
      , line = Some "!include {{ dovecot_auth_file | basename }}"
      , state = Some "present"
      , regex = None Text
      , regexp = None Text
      , create = None Bool
      , owner = None Text
      , group = None Text
      , insertafter = None Text
      , mode = None Natural
      , insertbefore = None Text
    }
    }
]
