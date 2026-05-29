-- Auto-generated from keys.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create private key",
      shell = Some "umask 077; wg genkey | tee privatekey | wg pubkey > publickey",
      args = Some {
        creates = Some "privatekey"
      , chdir = Some "/etc/wireguard"
      , executable = None Text
      , removes = None Text
    }
    }
  , Task::{
      name = Some "Retrieve public key",
      fetch = Some {
        src = "/etc/wireguard/publickey"
      , dest = "files/wireguard/{{ inventory_hostname }}"
      , flat = True
    }
    }
]
