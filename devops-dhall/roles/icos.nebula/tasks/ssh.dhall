-- Auto-generated from ssh.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Generate admin ssh key",
      command = Some ''
      ssh-keygen -q -t ed25519
        -f {{ nebula_ssh_key }}
        -C "nebula admin on {{ nebula_hostname }}" -N ""
    '',
      args = Some {
        creates = Some "{{ nebula_etc_dir }}/admin"
      , chdir = None Text
      , executable = None Text
      , removes = None Text
    }
    }
  , Task::{
      name = Some "Slurp nebula_ssh_public",
      slurp = Some { src = "{{ nebula_ssh_key }}.pub" },
      register = Some "_slurp"
    }
  , Task::{
      name = Some "Decode nebula_ssh_public",
      set_fact = Some {
        certbot_nginx_conf = None Text
      , destjarfile = None Text
      , name = None Text
      , nebula_resolve_type = None Text
      , cacheable = None Bool
      , nebula_ssh_public = Some "{{ _slurp.content | b64decode }}"
      , quince_tomcat_dir = None Text
      , sshlogin_src_user = None Text
      , sshlogin_dst_user = None Text
      , _wg_is_installed = None Natural
    }
    }
]
