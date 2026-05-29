-- Auto-generated from ../../../../devops/roles/icos.vmagent/tasks/systemd.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create prometheus.yml",
      copy = Some {
        dest = "{{ vmagent_home }}/prometheus.yml",
        mode = None Text,
        content = Some "{{ vmagent_conf }}",
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "reload vmagent" ]
    }
  , Task::{
      name = Some "Create vmagent environ file",
      template = Some {
        src = "vmagent.environ",
        dest = "{{ vmagent_environ }}",
        mode = Some "0600",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "restart vmagent" ]
    }
  , Task::{
      name = Some "Create vmagent service file",
      template = Some {
        src = "vmagent.service",
        dest = "{{ vmagent_home }}/vmagent.service",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "restart vmagent" ]
    }
  , Task::{
      name = Some "Link service",
      command = Some "systemctl link {{ vmagent_home }}/vmagent.service",
      args = Some {
        chdir = None Text,
        creates = Some "/etc/systemd/system/vmagent.service",
        executable = None Text,
        removes = None Text
    }
    }
  , Task::{
      name = Some "Start vmagent service",
      systemd = Some {
        name = Some "vmagent",
        state = Some "started",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
