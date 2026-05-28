-- Auto-generated from systemd.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , notify : Optional Text
    , template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Bool })
    , command : Optional Text
    , args : Optional ({ creates : Text })
    , systemd : Optional ({ name : Text, state : Text, enabled : Bool })
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , notify = None Text
    , template = None ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Bool })
    , command = None Text
    , args = None ({ creates : Text })
    , systemd = None ({ name : Text, state : Text, enabled : Bool })
  }
    }

in  [
    Task::{
      name = "Create prometheus.yml",
      copy = Some { dest = "{{ vmagent_home }}/prometheus.yml", content = "{{ vmagent_conf }}" },
      notify = Some "reload vmagent"
    }
  , Task::{
      name = "Create vmagent environ file",
      notify = Some "restart vmagent",
      template = Some {
        dest = "{{ vmagent_environ }}"
      , src = "vmagent.environ"
      , mode = Some "0600"
      , lstrip_blocks = True
    }
    }
  , Task::{
      name = "Create vmagent service file",
      notify = Some "restart vmagent",
      template = Some {
        dest = "{{ vmagent_home }}/vmagent.service"
      , src = "vmagent.service"
      , mode = None Text
      , lstrip_blocks = True
    }
    }
  , Task::{
      name = "Link service",
      command = Some "systemctl link {{ vmagent_home }}/vmagent.service",
      args = Some { creates = "/etc/systemd/system/vmagent.service" }
    }
  , Task::{
      name = "Start vmagent service",
      systemd = Some { name = "vmagent", state = "started", enabled = True }
    }
]
