-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_tasks = Some "jarfile.yml",
      tags = Some [ "jarservice_jarfile" ],
      when = Some [ "jarservice_jar_enable | bool" ]
    }
  , Task::{
      name = Some "Add systemd {{ jarservice_name }} servicefile",
      copy = Some {
        src = None Text
      , dest = "/etc/systemd/system/{{ jarservice_name }}.service"
      , mode = None Text
      , content = Some "{{ jarservice_unit }}"
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "reload systemd config" ]
    }
  , Task::{
      name = Some "Enable systemd {{ jarservice_name }}",
      service = Some {
        name = "{{ jarservice_name }}"
      , state = "{{ jarservice_state | default('started') }}"
      , enabled = Some True
    }
    }
  , Task::{
      name = Some "Check that the service responds",
      when = Some [ "jarservice_check is defined" ],
      uri = Some {
        url = "{{ jarservice_check }}"
      , return_content = Some True
      , method = None Text
      , user = None Text
      , password = None Text
    },
      register = Some "r",
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
  , Task::{
      name = Some "Check that the gitHash is correct",
      `assert` = Some { that = [ "jarservice_githash in r.content" ], quiet = None Bool },
      when = Some [ "jarservice_check is defined", "jarservice_githash is defined" ]
    }
]
