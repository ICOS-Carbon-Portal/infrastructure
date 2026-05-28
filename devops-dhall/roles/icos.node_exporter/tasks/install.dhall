-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, shell : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ dbin_download_dest : Text, dbin_user : Text, dbin_repo : Text, dbin_path : Text, dbin_arch : Text })
    , file : Optional ({ path : Text, mode : Text, state : Text })
    , template : Optional ({ dest : Text, src : Text })
    , loop : Optional (List Text)
    , notify : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , systemd : Optional ({ `daemon-reload` : Bool, name : Text, enabled : Bool, state : Text })
    , iptables_raw : Optional ({ name : Text, state : Text, rules : Text })
  }
    , default =
        { user = None ({ name : Text, home : Text, shell : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ dbin_download_dest : Text, dbin_user : Text, dbin_repo : Text, dbin_path : Text, dbin_arch : Text })
    , file = None ({ path : Text, mode : Text, state : Text })
    , template = None ({ dest : Text, src : Text })
    , loop = None (List Text)
    , notify = None Text
    , copy = None ({ dest : Text, content : Text })
    , systemd = None ({ `daemon-reload` : Bool, name : Text, enabled : Bool, state : Text })
    , iptables_raw = None ({ name : Text, state : Text, rules : Text })
  }
    }

in  [
    Task::{
      name = "Create node_exporter user",
      user = Some {
        name = "{{ node_exporter_user }}"
      , home = "{{ node_exporter_home }}"
      , shell = "/usr/sbin/nologin"
    }
    }
  , Task::{
      name = "Download node_exporter",
      include_role = Some { name = "icos.github_download_bin" },
      vars = Some {
        dbin_download_dest = "{{ node_exporter_download }}"
      , dbin_user = "prometheus"
      , dbin_repo = "node_exporter"
      , dbin_path = "node_exporter"
      , dbin_arch = "{{ node_exporter_arch }}"
    }
    }
  , Task::{
      name = "Create the textfile collector directory",
      file = Some { path = "{{ node_exporter_textfiles }}", mode = "1777", state = "directory" }
    }
  , Task::{
      name = "Copy node-exporter systemd files",
      template = Some { dest = "/etc/systemd/system/", src = "{{ item }}" },
      loop = Some [ "node-exporter.service", "node-exporter.socket" ],
      notify = Some "restart node-exporter"
    }
  , Task::{
      name = "Create the EnvironmentFile used by the systemd service",
      copy = Some {
        dest = "{{ node_exporter_environ }}"
      , content = ''
        OPTIONS=--collector.textfile.directory={{ node_exporter_textfiles }}

      ''
    }
    }
  , Task::{
      name = "Enable and start node-exporter.socket",
      systemd = Some {
        `daemon-reload` = True
      , name = "node-exporter.socket"
      , enabled = True
      , state = "started"
    }
    }
  , Task::{
      name = "Allow node_exporter through firewall",
      iptables_raw = Some {
        name = "allow_node_exporter"
      , state = "{{ 'present' if node_exporter_allow else 'absent' }}"
      , rules = "-A INPUT -p tcp --dport {{ node_exporter_listen }} -j ACCEPT"
    }
    }
]
