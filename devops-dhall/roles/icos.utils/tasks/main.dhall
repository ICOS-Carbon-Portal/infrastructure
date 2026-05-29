-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create common aliases",
      tags = Some [ "alias" ],
      copy = Some {
        src = None Text
      , dest = "/etc/profile.d/aliases.sh"
      , mode = None Text
      , content = Some ''
        alias sc=systemctl
        alias jc=journalctl
        alias df='df -h -x tmpfs -x overlay -x devtmpfs'
        alias dc='docker compose'
        alias psc='ps xawf -eo pid,user,cgroup,args'

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Copy utilities",
      tags = Some [ "utils_copy" ],
      template = Some {
        src = "{{ item }}"
      , dest = "/usr/local/sbin/{{ item }}"
      , mode = Some "493"
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      loop = Some [ "retrieve-original", "iptables-remove-duplicates", "ss", "ssh-merge-config" ]
    }
  , Task::{
      name = Some "Install utilities",
      apt = Some {
        name = Some [
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
      , state = None Text
      , update_cache = Some True
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{ import_tasks = Some "ripgrep.yml", tags = Some [ "ripgrep" ] }
  , Task::{ import_tasks = Some "ncdu.yml", tags = Some [ "ncdu" ] }
  , Task::{ import_tasks = Some "fd.yml", tags = Some [ "fd" ] }
  , Task::{ import_tasks = Some "watchexec.yml", tags = Some [ "watchexec" ] }
  , Task::{ import_tasks = Some "btop.yml", tags = Some [ "btop" ] }
  , Task::{ import_tasks = Some "trippy.yml", tags = Some [ "trippy" ] }
  , Task::{ import_tasks = Some "lazygit.yml", tags = Some [ "lazygit" ] }
]
