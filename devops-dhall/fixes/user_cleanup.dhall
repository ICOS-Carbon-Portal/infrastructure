-- Auto-generated from ../../devops/fixes/user_cleanup.yml

let Task = ../types/Task.dhall

in  [
    {
      hosts = "physical_servers fsicos2_vms fsicos3_vms"
    , vars = { lockuser = "username", remove_keys = [ "ssh-rsa..." ] }
    , tasks = [
        Task::{
          name = Some "Fetch root authorized_keys",
          tags = Some [ "fetch" ],
          fetch = Some { src = "/root/.ssh/authorized_keys", dest = "/tmp/ssh-pub-keys/", flat = None Bool }
        }
      , Task::{
          name = Some "Remove specific root key",
          tags = Some [ "remove" ],
          authorized_key = Some {
            user = "root",
            key = "{{ item }}",
            state = Some "absent",
            exclusive = None Bool,
            key_options = None Text
        },
          loop = Some (Task.Poly_loop.Str "{{ remove_keys }}")
        }
      , Task::{
          tags = Some [ "lockuser" ],
          user = Some {
            name = "{{ lockuser }}",
            uid = None Text,
            group = None Text,
            password = None Text,
            non_unique = None Bool,
            create_home = None Text,
            shell = Some "/usr/sbin/nologin",
            home = None Text,
            password_lock = Some True,
            groups = None ((List Text)),
            append = None Text,
            state = None Text,
            system = None Bool,
            generate_ssh_key = None Bool,
            remove = None Text
        }
        }
    ]
  }
]
