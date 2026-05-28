-- Auto-generated from main.yml

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
      `assert` = Some { that = "timer_home != \"/etc/systemd/systemd\"" },
      changed_when = Some "False",
      when = Some "timer_content is defined"
    }
  , Task::{
      name = "Create home directory",
      when = Some "timer_home != \"/etc/systemd/systemd\"",
      file = Some { path = "{{ timer_home }}", state = "directory" }
    }
  , Task::{
      name = "Create timer script",
      when = Some "timer_content is defined",
      copy = Some { dest = "{{ timer_dest }}", mode = Some "+x", content = "{{ timer_content }}" }
    }
  , Task::{
      name = "Create systemd timer definition",
      copy = Some {
        dest = "{{ _timer_sysd_timer }}"
      , mode = None Text
      , content = ''
        [Unit]
        Description={{ timer_desc }}

        [Timer]
        {{ timer_conf }}

        [Install]
        WantedBy=timers.target

      ''
    },
      notify = Some "restart icos timer"
    }
  , Task::{
      name = "Create systemd service",
      copy = Some {
        dest = "{{ _timer_sysd_service }}"
      , mode = None Text
      , content = ''
        [Unit]
        Description={{ timer_desc }}

        [Service]
        User={{ timer_user }}
        Type=oneshot
        ExecStart={{ timer_exec }}
        {% for env in timer_envs | default([]) -%}
        Environment={{ env }}
        {% endfor -%}
        {% if timer_wdir %}
        WorkingDirectory={{ timer_wdir }}
        {% endif %}

      ''
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
      when = Some "not ansible_check_mode",
      systemd = Some {
        name = "{{ timer_name }}.timer"
      , enabled = True
      , state = "started"
      , daemon_reload = True
    }
    }
]
