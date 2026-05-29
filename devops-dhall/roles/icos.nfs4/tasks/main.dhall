-- Auto-generated from ../../../../devops/roles/icos.nfs4/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install nfs",
      apt = Some {
        name = Some [ "nfs-kernel-server" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Allow nfs through firewall",
      when = Some [ "nfs4_interface" ],
      iptables_raw = Some {
        name = "allow_nfs4",
        rules = Some "-A INPUT {{ \"-i %s\" % nfs4_interface if nfs4_interface else \"\" }} -p tcp --dport 2049 -j ACCEPT",
        table = None Text,
        state = None Text,
        weight = None Natural
    }
    }
  , Task::{
      name = Some "Modify nfs-kernel parameters",
      lineinfile = Some {
        path = "/etc/default/nfs-kernel-server",
        regex = Some "^{{ item }}=",
        line = Some ''
        {{ item }}="--no-nfs-version 2 --no-nfs-version 3 --nfs-version 4 --no-udp"

      '',
        state = Some "present",
        backrefs = None Bool,
        regexp = None Text,
        create = None Bool,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "RPCNFSDOPTS", "RPCMOUNTDOPTS" ]),
      notify = Some [ "restart nfs-kernel-server" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "nfs4_just" ] }
]
