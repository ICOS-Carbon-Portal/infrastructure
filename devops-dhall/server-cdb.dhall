-- Auto-generated from ../devops/server-cdb.yml

let Task = ./types/Task.dhall

in  [
    {
      hosts = "cdb"
    , roles = [
        { role = "icos.server", tags = "server" }
      , { role = "icos.lxd_server", tags = "lxd_server" }
      , { role = "icos.bbserver", tags = "bbserver" }
      , { role = "icos.caddy", tags = "caddy" }
    ]
    , tasks = [
        Task::{
          name = Some "Allow ssh and mosh",
          tags = Some [ "iptables" ],
          iptables_raw = Some {
            name = "host_ssh_and_mosh",
            rules = Some ''
            -A INPUT -p tcp --dport 22 -j ACCEPT -m comment --comment 'ssh'
            -A INPUT -p udp -m multiport --dports 60000:61000 -j ACCEPT -m comment --comment "mosh"

          '',
            table = None Text,
            state = None Text,
            weight = None Natural
        }
        }
    ]
  }
]
