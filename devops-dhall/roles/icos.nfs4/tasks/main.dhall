-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install nfs",
      apt = Some {
        name = Some [ "nfs-kernel-server" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Allow nfs through firewall",
      when = Some [ "nfs4_interface" ],
      iptables_raw = Some {
        name = "allow_nfs4"
      , rules = Some "-A INPUT {{ \"-i %s\" % nfs4_interface if nfs4_interface else \"\" }} -p tcp --dport 2049 -j ACCEPT"
      , weight = None Natural
      , table = None Text
      , state = None Text
    }
    }
  , Task::{
      name = Some "Modify nfs-kernel parameters",
      lineinfile = Some {
        path = "/etc/default/nfs-kernel-server"
      , line = Some ''
        {{ item }}="--no-nfs-version 2 --no-nfs-version 3 --nfs-version 4 --no-udp"

      ''
      , state = Some "present"
      , regex = Some "^{{ item }}="
      , regexp = None Text
      , create = None Bool
      , owner = None Text
      , group = None Text
      , insertafter = None Text
      , mode = None Natural
      , insertbefore = None Text
    },
      loop = Some [ "RPCNFSDOPTS", "RPCMOUNTDOPTS" ],
      notify = Some [ "restart nfs-kernel-server" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "nfs4_just" ] }
]
