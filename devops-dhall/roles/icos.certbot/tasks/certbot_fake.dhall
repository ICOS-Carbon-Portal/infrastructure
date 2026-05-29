-- Auto-generated from ../../../../devops/roles/icos.certbot/tasks/certbot_fake.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ include_vars = Some "vars/{{ ansible_distribution | lower }}.yml" }
  , Task::{
      name = Some "Create self-signed certificate",
      command = Some ''
      openssl req -x509 -nodes -subj '/CN={{ certbot_fake_cn }}' -days 365 -newkey rsa:4096 -sha256 -keyout {{ certbot_fake_key }} -out {{ certbot_fake_crt }}

    '',
      args = Some {
        chdir = None Text,
        creates = Some "{{ certbot_fake_crt }}",
        executable = None Text,
        removes = None Text
    }
    }
  , Task::{
      name = Some "Create nginx config string",
      set_fact = Some (Task.Poly_set_fact.Record {
          certbot_nginx_conf = Some ''
          ssl_certificate {{ certbot_fake_crt }};
          ssl_certificate_key {{ certbot_fake_key}};

        '',
          destjarfile = None Text,
          name = None Text,
          nebula_resolve_type = None Text,
          cacheable = None Bool,
          nebula_ssh_public = None Text,
          quince_tomcat_dir = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text,
          _wg_is_installed = None Natural
      })
    }
]
