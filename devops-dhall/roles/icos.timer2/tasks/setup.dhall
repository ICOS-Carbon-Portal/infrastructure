-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Don't create timer script in /etc/systemd/system",
      `assert` = Some { that = [ "timer_home != \"/etc/systemd/system\"" ], quiet = None Bool },
      changed_when = Some "False",
      when = Some [ "timer_content is defined" ]
    }
  , Task::{
      name = Some "Create home directory",
      file = Some {
        path = Some "{{ timer_home }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Create timer script",
      copy = Some {
        src = None Text
      , dest = "{{ timer_dest }}"
      , mode = Some "+x"
      , content = Some "{{ timer_content }}"
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      when = Some [ "timer_content is defined" ]
    }
  , Task::{
      name = Some "Create systemd timer",
      copy = Some {
        src = None Text
      , dest = "{{ _timer_sysd_timer }}"
      , mode = None Text
      , content = Some "{{ timer_config }}"
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "restart icos timer" ]
    }
  , Task::{
      name = Some "Create systemd service",
      copy = Some {
        src = None Text
      , dest = "{{ _timer_sysd_service }}"
      , mode = None Text
      , content = Some "{{ timer_service }}"
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Link systemd files",
      when = Some [ "timer_home != \"/etc/systemd/system\"" ],
      command = Some "systemctl link {{ _timer_sysd_timer }} {{ _timer_sysd_service }}",
      register = Some "_r",
      failed_when = Some "_r.rc != 0",
      changed_when = Some "\"Created\" in _r.stdout"
    }
  , Task::{
      name = Some "Start timer",
      systemd = Some {
        name = Some "{{ timer_name }}.timer"
      , state = Some "{{ timer_state }}"
      , daemon_reload = Some True
      , enabled = Some "True"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
