-- Auto-generated from xcaddy.yml

let Item =
    { Type =
        { import_role : Optional Text
    , name : Optional Text
    , command : Optional Text
    , args : Optional ({ chdir : Text, creates : Text })
    , notify : Optional Text
    , file : Optional ({ path : Text, state : Optional Text, mode : Optional Text })
    , copy : Optional ({ dest : Text, content : Text })
  }
    , default =
        { import_role = None Text
    , name = None Text
    , command = None Text
    , args = None ({ chdir : Text, creates : Text })
    , notify = None Text
    , file = None ({ path : Text, state : Optional Text, mode : Optional Text })
    , copy = None ({ dest : Text, content : Text })
  }
    }

in  [
    Item::{ import_role = Some "name=icos.xcaddy" }
  , Item::{
      name = Some "Compile caddy using xcaddy",
      command = Some "xcaddy build --output {{ caddy_via_xcaddy }} {% for module in caddy_modules %} --with {{ module }} {% endfor %}",
      args = Some { chdir = "/tmp", creates = "{{ caddy_via_xcaddy }}" },
      notify = Some "restart caddy"
    }
  , Item::{
      name = Some "Create caddy systemd drop-in directory",
      file = Some {
        path = "{{ caddy_dropin_path | dirname }}"
      , state = Some "directory"
      , mode = None Text
    }
    }
  , Item::{
      name = Some "Create caddy systemd drop-in file",
      notify = Some "restart caddy",
      copy = Some {
        dest = "{{ caddy_dropin_path }}"
      , content = ''
        [Service]
        ExecStart=
        ExecStart={{ caddy_via_xcaddy }} run --environ --config /etc/caddy/Caddyfile
        ExecReload=
        ExecReload={{ caddy_via_xcaddy }} reload --config /etc/caddy/Caddyfile --force

      ''
    }
    }
  , Item::{
      name = Some "Make /usr/bin/caddy non-executable to avoid confusion",
      file = Some { path = "/usr/bin/caddy", state = None Text, mode = Some "-x" }
    }
]
