-- Auto-generated from vm-molefractions.yml

let Play =
    { Type =
        { hosts : Text
    , pre_tasks : Optional (List ({ name : Text, tags : Text, lxd_container : { name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, molefractions : { path : Text, source : Text, type : Text, readonly : Text }, ct2018 : { path : Text, source : Text, type : Text, readonly : Text }, cams : { path : Text, source : Text, type : Text, readonly : Text } }, config : { `limits.cpu` : Text, `limits.memory` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }, register : Text }))
    , roles : List ({ role : Text, lxd_forward_ip : Optional Text, lxd_forward_name : Optional Text, tags : Optional Text })
    , vars : Optional ({ username : Text })
    , handlers : Optional (List ({ name : Text, shell : Text, changed_when : Bool }))
    , tasks : Optional (List ({ name : Text, user : Optional ({ name : Text, shell : Text, create_home : Bool, password_lock : Bool }), blockinfile : Optional ({ marker : Text, path : Text, block : Text, insertbefore : Optional Text }), notify : Optional Text, copy : Optional ({ dest : Text, src : Text, mode : Text }), debug : Optional ({ msg : Text }) }))
  }
    , default =
        { pre_tasks = None (List ({ name : Text, tags : Text, lxd_container : { name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, molefractions : { path : Text, source : Text, type : Text, readonly : Text }, ct2018 : { path : Text, source : Text, type : Text, readonly : Text }, cams : { path : Text, source : Text, type : Text, readonly : Text } }, config : { `limits.cpu` : Text, `limits.memory` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }, register : Text }))
    , vars = None ({ username : Text })
    , handlers = None (List ({ name : Text, shell : Text, changed_when : Bool }))
    , tasks = None (List ({ name : Text, user : Optional ({ name : Text, shell : Text, create_home : Bool, password_lock : Bool }), blockinfile : Optional ({ marker : Text, path : Text, block : Text, insertbefore : Optional Text }), notify : Optional Text, copy : Optional ({ dest : Text, src : Text, mode : Text }), debug : Optional ({ msg : Text }) }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      pre_tasks = Some [
        {
          name = "Create the molefractions container"
        , tags = "lxd"
        , lxd_container = {
            name = "molefractions"
          , state = "started"
          , profiles = [ "default", "ssh_root" ]
          , source = {
              type = "image"
            , mode = "pull"
            , server = "https://cloud-images.ubuntu.com/releases"
            , protocol = "simplestreams"
            , alias = "20.04"
          }
          , devices = {
              root = {
                path = "/"
              , pool = "default"
              , type = "disk"
              , size = "20GB"
            }
            , molefractions = {
                path = "/data/molefractions/CTE_CO2_3D_molefractions"
              , source = "/data/common/netcdf/CTE_CO2_3D_molefractions"
              , type = "disk"
              , readonly = "true"
            }
            , ct2018 = {
                path = "/data/flexpart/CT2018"
              , source = "/data/flexpart/CT2018"
              , type = "disk"
              , readonly = "true"
            }
            , cams = {
                path = "/data/common/CAMS"
              , source = "/data/common/CAMS"
              , type = "disk"
              , readonly = "true"
            }
          }
          , config = { `limits.cpu` = "1", `limits.memory` = "2GB" }
          , wait_for_ipv4_addresses = True
          , wait_for_ipv4_interfaces = "eth0"
          , timeout = 60
        }
        , register = "_lxd"
      }
    ],
      roles = [
        {
          role = "icos.lxd_forward",
          lxd_forward_ip = Some "{{ _lxd.addresses.eth0 | first }}",
          lxd_forward_name = Some "molefractions",
          tags = None Text
        }
    ]
    }
  , Play::{
      hosts = "molefractions",
      roles = [
        {
          role = "icos.lxd_guest",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "guest"
        }
    ],
      vars = Some { username = "anonymous" },
      handlers = Some [
        {
          name = "reload sshd"
        , shell = "sshd -t && systemctl reload sshd"
        , changed_when = False
      }
    ],
      tasks = Some [
        {
          name = "add {{ username }} user",
          user = Some {
            name = "{{ username }}"
          , shell = "/sbin/nologin"
          , create_home = False
          , password_lock = True
        },
          blockinfile = None ({ marker : Text, path : Text, block : Text, insertbefore : Optional Text }),
          notify = None Text,
          copy = None ({ dest : Text, src : Text, mode : Text }),
          debug = None ({ msg : Text })
        }
      , {
          name = "set sshd sftp chroot",
          user = None ({ name : Text, shell : Text, create_home : Bool, password_lock : Bool }),
          blockinfile = Some {
            marker = "# {mark} ansible sftp chroot"
          , path = "/etc/ssh/sshd_config"
          , block = ''
            Match User {{ username }}
              ChrootDirectory /data
              ForceCommand internal-sftp
              DisableForwarding yes
              PasswordAuthentication yes

          ''
          , insertbefore = None Text
        },
          notify = Some "reload sshd",
          copy = None ({ dest : Text, src : Text, mode : Text }),
          debug = None ({ msg : Text })
        }
      , {
          name = "Create pam_sftp",
          user = None ({ name : Text, shell : Text, create_home : Bool, password_lock : Bool }),
          blockinfile = None ({ marker : Text, path : Text, block : Text, insertbefore : Optional Text }),
          notify = None Text,
          copy = Some { dest = "/usr/sbin/pam_sftp", src = "files/pam_sftp", mode = "+x" },
          debug = None ({ msg : Text })
        }
      , {
          name = "Add pam_sftp rule",
          user = None ({ name : Text, shell : Text, create_home : Bool, password_lock : Bool }),
          blockinfile = Some {
            marker = "# {mark} ansible / molefractions"
          , path = "/etc/pam.d/sshd"
          , block = ''
            auth sufficient pam_exec.so expose_authtok debug log=/var/log/pam_sftp.log /usr/sbin/pam_sftp

          ''
          , insertbefore = Some "BOF"
        },
          notify = None Text,
          copy = None ({ dest : Text, src : Text, mode : Text }),
          debug = None ({ msg : Text })
        }
      , {
          name = "Print ssh config",
          user = None ({ name : Text, shell : Text, create_home : Bool, password_lock : Bool }),
          blockinfile = None ({ marker : Text, path : Text, block : Text, insertbefore : Optional Text }),
          notify = None Text,
          copy = None ({ dest : Text, src : Text, mode : Text }),
          debug = Some {
            msg = ''
            Host {{ inventory_hostname }}
              HostName {{ ansible_host }}
              Port {{ ansible_port }}
              User {{ username }}
              PreferredAuthentications password

          ''
        }
        }
    ]
    }
]
