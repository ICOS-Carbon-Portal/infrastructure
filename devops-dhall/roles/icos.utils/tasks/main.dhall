-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , tags : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , template : Optional ({ src : Text, dest : Text, mode : Natural })
    , loop : Optional (List Text)
    , apt : Optional ({ update_cache : Bool, name : List Text })
    , import_tasks : Optional Text
  }
    , default =
        { name = None Text
    , tags = None Text
    , copy = None ({ dest : Text, content : Text })
    , template = None ({ src : Text, dest : Text, mode : Natural })
    , loop = None (List Text)
    , apt = None ({ update_cache : Bool, name : List Text })
    , import_tasks = None Text
  }
    }

in  [
    Item::{
      name = Some "Create common aliases",
      tags = Some "alias",
      copy = Some {
        dest = "/etc/profile.d/aliases.sh"
      , content = ''
        alias sc=systemctl
        alias jc=journalctl
        alias df='df -h -x tmpfs -x overlay -x devtmpfs'
        alias dc='docker compose'
        alias psc='ps xawf -eo pid,user,cgroup,args'

      ''
    }
    }
  , Item::{
      name = Some "Copy utilities",
      tags = Some "utils_copy",
      template = Some { src = "{{ item }}", dest = "/usr/local/sbin/{{ item }}", mode = 493 },
      loop = Some [ "retrieve-original", "iptables-remove-duplicates", "ss", "ssh-merge-config" ]
    }
  , Item::{
      name = Some "Install utilities",
      apt = Some {
        update_cache = True
      , name = [
          "mg"
        , "htop"
        , "jq"
        , "make"
        , "netcat-openbsd"
        , "git"
        , "tree"
        , "tcpdump"
        , "mutt"
        , "unzip"
      ]
    }
    }
  , Item::{ tags = Some "ripgrep", import_tasks = Some "ripgrep.yml" }
  , Item::{ tags = Some "ncdu", import_tasks = Some "ncdu.yml" }
  , Item::{ tags = Some "fd", import_tasks = Some "fd.yml" }
  , Item::{ tags = Some "watchexec", import_tasks = Some "watchexec.yml" }
  , Item::{ tags = Some "btop", import_tasks = Some "btop.yml" }
  , Item::{ tags = Some "trippy", import_tasks = Some "trippy.yml" }
  , Item::{ tags = Some "lazygit", import_tasks = Some "lazygit.yml" }
]
