-- Auto-generated from ../../../../devops/roles/icos.jarservice/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart {{ servicename }}",
      command = Some "systemctl restart {{ servicename }}"
    }
  , Task::{
      name = Some "reload systemd config",
      systemd = Some {
        name = None Text,
        state = None Text,
        daemon_reload = Some True,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "reload nginx config",
      command = Some "nginx -t",
      notify = Some [ "really reload nginx config" ]
    }
  , Task::{
      name = Some "really reload nginx config",
      service = Some (Task.Poly_service.Str "name=nginx state=reloaded")
    }
]
