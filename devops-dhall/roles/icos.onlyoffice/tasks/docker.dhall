-- Auto-generated from ../../../../devops/roles/icos.onlyoffice/tasks/docker.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy build directory",
      copy = Some {
        dest = "{{ onlyoffice_home }}/",
        mode = None Text,
        content = None Text,
        src = Some "build",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Install runtime environment file",
      copy = Some {
        dest = "{{ onlyoffice_home }}/onlyoffice.env",
        mode = Some "o-r",
        content = Some ''
        # JWT == JSON Web Tokens. This is how Nextcloud authenticates
        # itself to OnlyOffice.
        JWT_ENABLED=true
        JWT_SECRET={{ onlyoffice_secret | mandatory }}

        # Setting this to false will make the documentserver's entrypoint
        # script allow unauthorized HTTPS connections. Use only for testing.
        JWT_REJECT_UNAUTHORIZED=true

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Copy license.lic",
      copy = Some {
        dest = "{{ onlyoffice_home }}/volumes/data/",
        mode = None Text,
        content = None Text,
        src = Some "license.lic",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Copy docker-compose.yml",
      copy = Some {
        dest = "{{ onlyoffice_home }}",
        mode = None Text,
        content = None Text,
        src = Some "docker-compose.yml",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Install parsetime environment file",
      copy = Some {
        dest = "{{ onlyoffice_home }}/.env",
        mode = None Text,
        content = Some ''
        ONLYOFFICE_PORT={{ onlyoffice_port }}
        ONLYOFFICE_VERSION={{ onlyoffice_version }}

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Build and start",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ onlyoffice_home }}",
        state = None Text,
        pull = None Text,
        services = None ((List Text)),
        build = Some "always"
    }
    }
  , Task::{
      name = Some "Check that onlyoffice responds - might take a while",
      uri = Some {
        url = "https://{{ onlyoffice_domain }}",
        return_content = None Bool,
        method = None Text,
        user = None Text,
        password = None Text
    },
      retries = Some 60,
      delay = Some 10,
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
