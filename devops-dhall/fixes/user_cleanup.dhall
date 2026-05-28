-- Auto-generated from user_cleanup.yml

[
    {
      hosts = "physical_servers fsicos2_vms fsicos3_vms"
    , vars = { lockuser = "username", remove_keys = [ "ssh-rsa..." ] }
    , tasks = [
        {
          name = Some "Fetch root authorized_keys",
          tags = "fetch",
          fetch = Some { src = "/root/.ssh/authorized_keys", dest = "/tmp/ssh-pub-keys/" },
          authorized_key = None ({ user : Text, key : Text, state : Text }),
          loop = None Text,
          user = None ({ name : Text, password_lock : Bool, shell : Text })
        }
      , {
          name = Some "Remove specific root key",
          tags = "remove",
          fetch = None ({ src : Text, dest : Text }),
          authorized_key = Some { user = "root", key = "{{ item }}", state = "absent" },
          loop = Some "{{ remove_keys }}",
          user = None ({ name : Text, password_lock : Bool, shell : Text })
        }
      , {
          name = None Text,
          tags = "lockuser",
          fetch = None ({ src : Text, dest : Text }),
          authorized_key = None ({ user : Text, key : Text, state : Text }),
          loop = None Text,
          user = Some { name = "{{ lockuser }}", password_lock = True, shell = "/usr/sbin/nologin" }
        }
    ]
  }
]
