-- Auto-generated from flexpart_ssh_user.yml

[
    {
      name = "Run block as {{ _ssh_user }}"
    , become = True
    , become_user = "{{ _ssh_user }}"
    , block = [
        {
          name = "Get home directory of {{ _ssh_user }}",
          shell = Some "getent passwd {{ _ssh_user }} | cut -d: -f6",
          register = Some "_home_dir",
          changed_when = Some False,
          file = None ({ path : Text, state : Text, mode : Natural }),
          copy = None ({ src : Text, dest : Text, mode : Natural }),
          known_hosts = None ({ path : Text, name : Text, key : Text }),
          blockinfile = None ({ create : Bool, path : Text, mode : Natural, marker : Text, block : Text })
        }
      , {
          name = "Make sure user .ssh directory is present",
          shell = None Text,
          register = Some "_ssh_dir",
          changed_when = None Bool,
          file = Some { path = "{{ _home_dir.stdout }}/.ssh", state = "directory", mode = 448 },
          copy = None ({ src : Text, dest : Text, mode : Natural }),
          known_hosts = None ({ path : Text, name : Text, key : Text }),
          blockinfile = None ({ create : Bool, path : Text, mode : Natural, marker : Text, block : Text })
        }
      , {
          name = "Install the rsa private key",
          shell = None Text,
          register = Some "_rsa_file",
          changed_when = None Bool,
          file = None ({ path : Text, state : Text, mode : Natural }),
          copy = Some {
            src = "roles/icos.flexpart/files/flexpart.rsa"
          , dest = "{{ _ssh_dir.path}}/flexpart.rsa"
          , mode = 384
        },
          known_hosts = None ({ path : Text, name : Text, key : Text }),
          blockinfile = None ({ create : Bool, path : Text, mode : Natural, marker : Text, block : Text })
        }
      , {
          name = "Add flexpart run host to each users known_hosts file",
          shell = None Text,
          register = None Text,
          changed_when = None Bool,
          file = None ({ path : Text, state : Text, mode : Natural }),
          copy = None ({ src : Text, dest : Text, mode : Natural }),
          known_hosts = Some {
            path = "{{ _ssh_dir.path }}/known_hosts"
          , name = "{{ flexpart_ssh_remote_host }}"
          , key = "{{ flexpart_ssh_remote_host }},{{ flexpart_ssh_remote_ip }} ecdsa-sha2-nistp256 {{ hostvars[flexpart_ssh_remote_host].ansible_ssh_host_key_ecdsa_public }}"
        },
          blockinfile = None ({ create : Bool, path : Text, mode : Natural, marker : Text, block : Text })
        }
      , {
          name = "Add flexpart users ssh config file",
          shell = None Text,
          register = None Text,
          changed_when = None Bool,
          file = None ({ path : Text, state : Text, mode : Natural }),
          copy = None ({ src : Text, dest : Text, mode : Natural }),
          known_hosts = None ({ path : Text, name : Text, key : Text }),
          blockinfile = Some {
            create = True
          , path = "{{ _ssh_dir.path }}/config"
          , mode = 384
          , marker = "# {mark} ansible config for flexpart"
          , block = ''
            Host flexpart
              User {{ flexpart_user }}
              HostName {{ flexpart_ssh_remote_ip }}
              IdentityFile {{ _ssh_dir.path }}/flexpart.rsa

          ''
        }
        }
    ]
  }
]
