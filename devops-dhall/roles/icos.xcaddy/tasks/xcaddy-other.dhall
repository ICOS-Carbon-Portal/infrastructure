-- Auto-generated from xcaddy-other.yml

let Entry =
    { Type =
        { name : Text
    , command : Optional Text
    , args : Optional ({ creates : Text })
    , environment : Optional ({ GOPATH : Text })
    , file : Optional ({ dest : Text, src : Text, state : Text })
  }
    , default =
        { command = None Text
    , args = None ({ creates : Text })
    , environment = None ({ GOPATH : Text })
    , file = None ({ dest : Text, src : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Install xcaddy",
      command = Some "go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest",
      args = Some { creates = "{{ omit if xcaddy_upgrade else '/opt/xcaddy' }}" },
      environment = Some { GOPATH = "/opt/xcaddy" }
    }
  , Entry::{
      name = "Create /usr/local/bin/xcaddy symlink",
      file = Some { dest = "/usr/local/bin/xcaddy", src = "/opt/xcaddy/bin/xcaddy", state = "link" }
    }
]
