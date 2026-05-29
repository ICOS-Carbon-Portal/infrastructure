-- Auto-generated from ../../../../devops/roles/icos.nexus/tasks/nginx.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_role = Some (Task.Poly_import_role.Str "name=icos.certbot2"),
      when = Some [ "nexus_certbot_enable | default(True)" ]
    }
  , Task::{ import_role = Some (Task.Poly_import_role.Str "name=icos.nginxsite") }
  , Task::{
      name = Some "Check that nexus responds with correct version",
      uri = Some {
        url = "http://127.0.0.1:{{ nexus_host_port }}/service/local/status",
        return_content = Some True,
        method = None Text,
        user = None Text,
        password = None Text
    },
      register = Some "r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "not ((\"<version>%s</version>\" % nexus_version) in r.content)" ]),
      retries = Some 2,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
