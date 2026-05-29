-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Don't create timer script in /etc/systemd/system",
      `assert` = Some { that = [ "timer_home != \"/etc/systemd/systemd\"" ], quiet = None Bool },
      changed_when = Some "False",
      when = Some [ "timer_content is defined" ]
    }
  , Task::{
      name = Some "Create home directory",
      when = Some [ "timer_home != \"/etc/systemd/systemd\"" ],
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
      name = Some "Create systemd timer definition",
      copy = Some {
        src = None Text
      , dest = "{{ _timer_sysd_timer }}"
      , mode = None Text
      , content = Some ''
        [Unit]
        Description={{ timer_desc }}

        [Timer]
        {{ timer_conf }}

        [Install]
        WantedBy=timers.target

      ''
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
      , content = Some ''
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
      when = Some [ "not ansible_check_mode" ],
      systemd = Some {
        name = Some "{{ timer_name }}.timer"
      , state = Some "started"
      , daemon_reload = Some True
      , enabled = Some "True"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
