-- Auto-generated from terminal.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , register : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , systemd : Optional ({ daemon_reload : Bool })
    , when : Optional Text
    , blockinfile : Optional ({ marker : Text, create : Bool, insertafter : Text, path : Text, block : Text })
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , register = None Text
    , copy = None ({ dest : Text, content : Text })
    , systemd = None ({ daemon_reload : Bool })
    , when = None Text
    , blockinfile = None ({ marker : Text, create : Bool, insertafter : Text, path : Text, block : Text })
  }
    }

in  [
    Task::{
      name = "Create  directory",
      file = Some {
        path = "/etc/systemd/system/serial-getty@ttyS0.service.d"
      , state = "directory"
    },
      register = Some "_mkdir"
    }
  , Task::{
      name = "Create ttyS0 override",
      register = Some "_conf",
      copy = Some {
        dest = "{{ _mkdir.path }}/autologin.conf"
      , content = ''
        [Service]
        ExecStart=
        ExecStart=-/sbin/agetty -o '-p -- \\u' --keep-baud 115200,57600,38400,9600 --autologin root - $TERM

      ''
    }
    }
  , Task::{
      name = "systemd reload",
      systemd = Some { daemon_reload = True },
      when = Some "_conf.changed"
    }
  , Task::{
      name = "Add securetty config to pam",
      blockinfile = Some {
        marker = "# {mark} ansible / pve_guest"
      , create = True
      , insertafter = "BOF"
      , path = "/etc/pam.d/login"
      , block = ''
        auth sufficient pam_listfile.so item=tty sense=allow file=/etc/securetty onerr=fail apply=root

      ''
    }
    }
  , Task::{
      name = "Create /etc/securetty",
      copy = Some {
        dest = "/etc/securetty"
      , content = ''
        ttyS0

      ''
    }
    }
]
