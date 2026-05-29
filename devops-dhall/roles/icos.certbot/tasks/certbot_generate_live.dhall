-- Auto-generated from ../../../../devops/roles/icos.certbot/tasks/certbot_generate_live.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check if {{ certbot_conf_name }} exists",
      stat = Some { path = "{{ certbot_conf_path }}" },
      register = Some "_conf_file"
    }
  , Task::{
      name = Some "Create an initial nginx {{ certbot_conf_name }} for the certbot certification",
      copy = Some {
        dest = "{{ certbot_conf_path }}",
        mode = None Text,
        content = Some ''
        server {
          listen 80;
          server_name {% for domain in certbot_domains %} {{ domain }}{% endfor %};

          location /.well-known {
              root /usr/share/nginx/html;
          }
        }

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_write_conf",
      when = Some [ "not _conf_file.stat.exists" ]
    }
  , Task::{
      name = Some "Reload nginx",
      service = Some (Task.Poly_service.Record { name = "nginx", state = "reloaded", enabled = None Bool }),
      when = Some [ "_write_conf.changed" ]
    }
  , Task::{
      name = Some "Install SSL certificate",
      command = Some ''
      {{ certbot_bin }} certonly --authenticator nginx --non-interactive {% for domain in certbot_domains %} --domain {{ domain }} {% endfor %} --email {{ certbot_email }} --agree-tos --expand

    '',
      register = Some "o",
      changed_when = Some (Task.Poly_changed_when.Str "\"Certificate not yet due for renewal; no action taken.\" not in o.stdout")
    }
  , Task::{
      name = Some "Set nginx config variable",
      set_fact = Some (Task.Poly_set_fact.Record {
          certbot_nginx_conf = Some ''
          ssl_certificate {{ certbot_live_crt }};
          ssl_certificate_key {{ certbot_live_key }};

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
