-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Run certbot",
      command = Some ''
      {{ certbot_bin }}
      certonly
      --nginx
      --non-interactive
      --agree-tos
      --expand
      --cert-name {{ certbot_name }}
      --email {{ certbot_email }}
      {% for d in certbot_domains %} -d {{ d }} {% endfor %}

    '',
      register = Some "_r",
      changed_when = Some "'Successfully received certificate.' in _r.stdout"
    }
]
