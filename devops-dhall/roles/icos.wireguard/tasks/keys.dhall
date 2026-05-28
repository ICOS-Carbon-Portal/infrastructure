-- Auto-generated from keys.yml

let Task =
    { Type =
        { name : Text
    , shell : Optional Text
    , args : Optional ({ chdir : Text, creates : Text })
    , fetch : Optional ({ src : Text, dest : Text, flat : Bool })
  }
    , default =
        { shell = None Text
    , args = None ({ chdir : Text, creates : Text })
    , fetch = None ({ src : Text, dest : Text, flat : Bool })
  }
    }

in  [
    Task::{
      name = "Create private key",
      shell = Some "umask 077; wg genkey | tee privatekey | wg pubkey > publickey",
      args = Some { chdir = "/etc/wireguard", creates = "privatekey" }
    }
  , Task::{
      name = "Retrieve public key",
      fetch = Some {
        src = "/etc/wireguard/publickey"
      , dest = "files/wireguard/{{ inventory_hostname }}"
      , flat = True
    }
    }
]
