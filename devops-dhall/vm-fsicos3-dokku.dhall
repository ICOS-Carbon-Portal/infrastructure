-- Auto-generated from vm-fsicos3-dokku.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ dokku_wildcard_domains : List Text, dokku_static_domains : List Text, dokku_redirect_domains : List Text })
    , roles : List ({ name : Optional Text, role : Text, lxd_vm_name : Optional Text, lxd_vm_docker : Optional Bool, lxd_vm_docker_size : Optional Text, lxd_vm_root_size : Optional Text, lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text }), lxd_vm_ubuntu_version : Optional Text, tags : Optional Text, certbot_name : Optional Text, certbot_domains : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, dokku_proxy_host : Optional Text, dokku_proxy_port : Optional Natural })
    , tasks : Optional (List ({ name : Text, tags : Text, command : Text }))
  }
    , default =
        { vars = None ({ dokku_wildcard_domains : List Text, dokku_static_domains : List Text, dokku_redirect_domains : List Text })
    , tasks = None (List ({ name : Text, tags : Text, command : Text }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = Some {
        dokku_wildcard_domains = [ "*.app.icos-cp.eu" ]
      , dokku_static_domains = [ "curve.icos-ri.eu" ]
      , dokku_redirect_domains = [ "curve.icos-cp.eu" ]
    },
      roles = [
        {
          name = Some "Create the dokku VM",
          role = "icos.lxd_vm",
          lxd_vm_name = Some "dokku",
          lxd_vm_docker = Some True,
          lxd_vm_docker_size = Some "200GB",
          lxd_vm_root_size = Some "500GB",
          lxd_vm_config = Some { `limits.cpu` = "8", `limits.memory` = "64GB" },
          lxd_vm_ubuntu_version = Some "24.04",
          tags = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          dokku_proxy_host = None Text,
          dokku_proxy_port = None Natural
        }
      , {
          name = None Text,
          role = "icos.certbot2",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_docker_size = None Text,
          lxd_vm_root_size = None Text,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_ubuntu_version = None Text,
          tags = Some "cert",
          certbot_name = Some "dokku",
          certbot_domains = Some "{{ (dokku_static_domains + dokku_redirect_domains) }}",
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          dokku_proxy_host = None Text,
          dokku_proxy_port = None Natural
        }
      , {
          name = None Text,
          role = "icos.nginxsite",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_docker_size = None Text,
          lxd_vm_root_size = None Text,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_ubuntu_version = None Text,
          tags = Some "nginx",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = Some "dokku",
          nginxsite_file = Some "templates/dokku-nginx.conf",
          dokku_proxy_host = Some "dokku.lxd",
          dokku_proxy_port = Some 80
        }
    ],
      tasks = Some [
        {
          name = "Add LXD disk device for dokku"
        , tags = "dokku_add_device"
        , command = ''
          lxc config device add dokku flexpart disk source=/data/cupcake path=/data/flexpart/output shift=true

        ''
      }
    ]
    }
  , Play::{
      hosts = "dokku",
      roles = [
        {
          name = None Text,
          role = "icos.lxd_guest",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_docker_size = None Text,
          lxd_vm_root_size = None Text,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_ubuntu_version = None Text,
          tags = Some "guest",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          dokku_proxy_host = None Text,
          dokku_proxy_port = None Natural
        }
      , {
          name = None Text,
          role = "icos.docker2",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_docker_size = None Text,
          lxd_vm_root_size = None Text,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_ubuntu_version = None Text,
          tags = Some "docker",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          dokku_proxy_host = None Text,
          dokku_proxy_port = None Natural
        }
      , {
          name = None Text,
          role = "icos.dokku",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_docker_size = None Text,
          lxd_vm_root_size = None Text,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_ubuntu_version = None Text,
          tags = Some "dokku",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          dokku_proxy_host = None Text,
          dokku_proxy_port = None Natural
        }
    ]
    }
]
