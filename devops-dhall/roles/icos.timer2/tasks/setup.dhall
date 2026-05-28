-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , `assert` : Optional ({ that : Text })
    , changed_when : Optional Text
    , when : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , copy : Optional ({ dest : Text, mode : Optional Text, content : Text })
    , notify : Optional Text
    , command : Optional Text
    , register : Optional Text
    , failed_when : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text, daemon_reload : Bool })
  }
    , default =
        { `assert` = None ({ that : Text })
    , changed_when = None Text
    , when = None Text
    , file = None ({ path : Text, state : Text })
    , copy = None ({ dest : Text, mode : Optional Text, content : Text })
    , notify = None Text
    , command = None Text
    , register = None Text
    , failed_when = None Text
    , systemd = None ({ name : Text, enabled : Bool, state : Text, daemon_reload : Bool })
  }
    }

in  [
    Task::{
      name = "Don't create timer script in /etc/systemd/system",
      `assert` = Some { that = "timer_home != \"/etc/systemd/system\"" },
      changed_when = Some "False",
      when = Some "timer_content is defined"
    }
  , Task::{
      name = "Create home directory",
      file = Some { path = "{{ timer_home }}", state = "directory" }
    }
  , Task::{
      name = "Create timer script",
      when = Some "timer_content is defined",
      copy = Some { dest = "{{ timer_dest }}", mode = Some "+x", content = "{{ timer_content }}" }
    }
  , Task::{
      name = "Create systemd timer",
      copy = Some {
        dest = "{{ _timer_sysd_timer }}"
      , mode = None Text
      , content = "{{ timer_config }}"
    },
      notify = Some "restart icos timer"
    }
  , Task::{
      name = "Create systemd service",
      copy = Some {
        dest = "{{ _timer_sysd_service }}"
      , mode = None Text
      , content = "{{ timer_service }}"
    }
    }
  , Task::{
      name = "Link systemd files",
      changed_when = Some "\"Created\" in _r.stdout",
      when = Some "timer_home != \"/etc/systemd/system\"",
      command = Some "systemctl link {{ _timer_sysd_timer }} {{ _timer_sysd_service }}",
      register = Some "_r",
      failed_when = Some "_r.rc != 0"
    }
  , Task::{
      name = "Start timer",
      systemd = Some {
        name = "{{ timer_name }}.timer"
      , enabled = True
      , state = "{{ timer_state }}"
      , daemon_reload = True
    }
    }
]
