-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , apt : Optional ({ name : List Text })
    , when : Optional Text
    , iptables_raw : Optional ({ name : Text, rules : Text })
    , lineinfile : Optional ({ path : Text, regex : Text, line : Text, state : Text })
    , loop : Optional (List Text)
    , notify : Optional Text
    , import_tasks : Optional Text
    , tags : Optional Text
  }
    , default =
        { name = None Text
    , apt = None ({ name : List Text })
    , when = None Text
    , iptables_raw = None ({ name : Text, rules : Text })
    , lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text })
    , loop = None (List Text)
    , notify = None Text
    , import_tasks = None Text
    , tags = None Text
  }
    }

in  [
    Item::{ name = Some "Install nfs", apt = Some { name = [ "nfs-kernel-server" ] } }
  , Item::{
      name = Some "Allow nfs through firewall",
      when = Some "nfs4_interface",
      iptables_raw = Some {
        name = "allow_nfs4"
      , rules = "-A INPUT {{ \"-i %s\" % nfs4_interface if nfs4_interface else \"\" }} -p tcp --dport 2049 -j ACCEPT"
    }
    }
  , Item::{
      name = Some "Modify nfs-kernel parameters",
      lineinfile = Some {
        path = "/etc/default/nfs-kernel-server"
      , regex = "^{{ item }}="
      , line = ''
        {{ item }}="--no-nfs-version 2 --no-nfs-version 3 --nfs-version 4 --no-udp"

      ''
      , state = "present"
    },
      loop = Some [ "RPCNFSDOPTS", "RPCMOUNTDOPTS" ],
      notify = Some "restart nfs-kernel-server"
    }
  , Item::{ import_tasks = Some "just.yml", tags = Some "nfs4_just" }
]
