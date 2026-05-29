-- Auto-generated from ../devops/server-fsicos4.yml

[
    {
      hosts = "fsicos4"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , fail2ban_config_files : Optional (List ({ dest : Text, content : Text }))
        , dnsmasq_interface : Optional Text
        , dnsmasq_config : Optional Text
        , rsyncd_enable : Optional Bool
        , rsyncd_users : Optional (List ({ name : Text }))
        , rsyncd_conf : Optional Text
      }
        , default =
            { fail2ban_config_files = None (List ({ dest : Text, content : Text }))
        , dnsmasq_interface = None Text
        , dnsmasq_config = None Text
        , rsyncd_enable = None Bool
        , rsyncd_users = None (List ({ name : Text }))
        , rsyncd_conf = None Text
      }
        }

    in  [
        Role::{ role = "icos.mosh", tags = "mosh" }
      , Role::{ role = "icos.caddy", tags = "caddy" }
      , Role::{ role = "icos.pve_server", tags = "pve_server" }
      , Role::{ role = "icos.utils", tags = "utils" }
      , Role::{ role = "icos.python3", tags = "python" }
      , Role::{
          role = "icos.fail2ban",
          tags = "fail2ban",
          fail2ban_config_files = Some [
            {
              dest = "/etc/fail2ban/jail.d/sshd-allports.local"
            , content = ''
              [sshd]
              # fail2ban won't start out of the box on proxmox8/debian12(?)
              # since it's configured to use /var/log/auth.log (which doesn't exist).
              # https://forum.proxmox.com/threads/missing-auth-log-in-proxmox-ve-8-0-fail2ban-sshd.130271/
              backend = systemd
              # Since we're running ssh on different ports that fail2ban is used
              # to, block all ports.
              banaction = iptables-allports

            ''
          }
        ]
        }
      , Role::{
          role = "icos.dnsmasq",
          tags = "dnsmasq",
          dnsmasq_interface = Some "vmbr0",
          dnsmasq_config = Some ''
          # bind only to the interface given on the command line
          bind-interfaces

          # the range of addresses available for lease
          dhcp-range=10.10.10.50,10.10.10.250,12h

          # set default route
          dhcp-option={{ dnsmasq_interface }},3,10.10.10.1

          dhcp-leasefile=/var/lib/misc/dnsmasq.{{ dnsmasq_interface }}.leases

        ''
        }
      , Role::{
          role = "icos.rsyncd",
          tags = "rsyncd",
          rsyncd_enable = Some True,
          rsyncd_users = Some [
            { name = "root" }
        ],
          rsyncd_conf = Some ''
          # only accept rsync on nebula interface
          address = fsicos4.nebula

          [data]
          # run this module as root instead of nobody
          uid = root
          gid = *
          comment = /tank/data
          path = /tank/data
          auth users = root:rw
          numeric ids
          secrets file = /etc/rsyncd.secrets
          hosts allow = fsicos2.nebula,fsicos3.nebula,icos1.nebula

        ''
        }
    ]
  }
]
