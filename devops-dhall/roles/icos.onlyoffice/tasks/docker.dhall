-- Auto-generated from docker.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, src : Optional Text, mode : Optional Text, content : Optional Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, build : Text })
    , uri : Optional ({ url : Text })
    , retries : Optional Natural
    , delay : Optional Natural
    , changed_when : Optional Bool
  }
    , default =
        { copy = None ({ dest : Text, src : Optional Text, mode : Optional Text, content : Optional Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Text })
    , uri = None ({ url : Text })
    , retries = None Natural
    , delay = None Natural
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Copy build directory",
      copy = Some {
        dest = "{{ onlyoffice_home }}/"
      , src = Some "build"
      , mode = None Text
      , content = None Text
    }
    }
  , Task::{
      name = "Install runtime environment file",
      copy = Some {
        dest = "{{ onlyoffice_home }}/onlyoffice.env"
      , src = None Text
      , mode = Some "o-r"
      , content = Some ''
        # JWT == JSON Web Tokens. This is how Nextcloud authenticates
        # itself to OnlyOffice.
        JWT_ENABLED=true
        JWT_SECRET={{ onlyoffice_secret | mandatory }}

        # Setting this to false will make the documentserver's entrypoint
        # script allow unauthorized HTTPS connections. Use only for testing.
        JWT_REJECT_UNAUTHORIZED=true

      ''
    }
    }
  , Task::{
      name = "Copy license.lic",
      copy = Some {
        dest = "{{ onlyoffice_home }}/volumes/data/"
      , src = Some "license.lic"
      , mode = None Text
      , content = None Text
    }
    }
  , Task::{
      name = "Copy docker-compose.yml",
      copy = Some {
        dest = "{{ onlyoffice_home }}"
      , src = Some "docker-compose.yml"
      , mode = None Text
      , content = None Text
    }
    }
  , Task::{
      name = "Install parsetime environment file",
      copy = Some {
        dest = "{{ onlyoffice_home }}/.env"
      , src = None Text
      , mode = None Text
      , content = Some ''
        ONLYOFFICE_PORT={{ onlyoffice_port }}
        ONLYOFFICE_VERSION={{ onlyoffice_version }}

      ''
    }
    }
  , Task::{
      name = "Build and start",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ onlyoffice_home }}", build = "always" }
    }
  , Task::{
      name = "Check that onlyoffice responds - might take a while",
      uri = Some { url = "https://{{ onlyoffice_domain }}" },
      retries = Some 60,
      delay = Some 10,
      changed_when = Some False
    }
]
