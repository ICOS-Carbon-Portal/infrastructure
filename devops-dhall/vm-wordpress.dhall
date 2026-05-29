-- Auto-generated from ../devops/vm-wordpress.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ wordpress_domains : List Text })
    , roles : List ({ role : Text, tags : Text, lxd_vm_name : Optional Text, lxd_vm_root_size : Optional Text, lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text }), certbot_name : Optional Text, certbot_domains : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text })
    , tasks : Optional (List ({ name : Text, debug : { msg : Text } }))
  }
    , default =
        { vars = None ({ wordpress_domains : List Text })
    , tasks = None (List ({ name : Text, debug : { msg : Text } }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      vars = Some {
        wordpress_domains = [
          "www.ingos-infrastructure.eu"
        , "eric-forum.eu"
        , "www.eric-forum.eu"
        , "www.icos-summerschool.eu"
        , "www.envriplus.eu"
        , "ggmt2022.online"
        , "www.ggmt2022.online"
        , "avengers-project.eu"
        , "www.avengers-project.eu"
        , "george-project.eu"
        , "www.george-project.eu"
        , "kadi-project.eu"
        , "www.kadi-project.eu"
      ]
    },
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text })
        , certbot_name : Optional Text
        , certbot_domains : Optional Text
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text })
        , certbot_name = None Text
        , certbot_domains = None Text
        , nginxsite_name = None Text
        , nginxsite_file = None Text
      }
        }

    in  [
        Role::{
          role = "icos.lxd_vm",
          tags = "lxd",
          lxd_vm_name = Some "wordpress",
          lxd_vm_root_size = Some "500GB",
          lxd_vm_config = Some { `limits.cpu` = "4", `limits.memory` = "8GB" }
        }
      , Role::{
          role = "icos.certbot2",
          tags = "cert",
          certbot_name = Some "wordpress",
          certbot_domains = Some "{{ wordpress_domains }}"
        }
      , Role::{
          role = "icos.nginxsite",
          tags = "nginx",
          nginxsite_name = Some "wordpress",
          nginxsite_file = Some "files/wordpress.conf"
        }
    ]
    }
  , Play::{
      hosts = "wordpress",
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text })
        , certbot_name : Optional Text
        , certbot_domains : Optional Text
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text })
        , certbot_name = None Text
        , certbot_domains = None Text
        , nginxsite_name = None Text
        , nginxsite_file = None Text
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = "guest" }
    ],
      tasks = Some [
        {
          name = "Print wp-config warning"
        , debug = {
            msg = ''
            # Don't forget to add the following in your wp-config.php, after the
            # WP_DEBUG line. Otherwise you'll get redirect loops.
            if ( $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' )
            {
                $_SERVER['HTTPS']       = 'on';
                $_SERVER['SERVER_PORT'] = 443;
            }

          ''
        }
      }
    ]
    }
]
