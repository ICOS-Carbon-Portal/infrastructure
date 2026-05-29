-- Auto-generated from ../devops/vm-flexextract.yml

[
    {
      hosts = "fsicos2",
      roles = [
        {
          name = Some "Create the flexextract VM",
          tags = "vm",
          role = "icos.lxd_vm",
          lxd_vm_name = Some "flexextract",
          lxd_vm_docker = Some True,
          lxd_vm_config = Some { `limits.cpu` = "14", `limits.memory` = "55GB" },
          lxd_vm_devices = Some {
            flexextract = {
              path = "/data/flexextract"
            , source = "/disk/data/flexextract"
            , type = "disk"
            , recursive = "true"
          }
          , flexextract_meteo = {
              path = "/data/flexextract/meteo"
            , source = "/nfs/flexextract_meteo"
            , type = "disk"
          }
          , flexpart_output = {
              path = "/data/flexpart/output"
            , source = "/data/flexpart/output"
            , type = "disk"
            , readonly = "False"
          }
        },
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          flexextract_src_dir = None Text,
          flexextract_download_host = None Text,
          sshlogin_dst = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text
        }
      , {
          name = None Text,
          tags = "cert",
          role = "icos.certbot2",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } }),
          certbot_name = Some "flexextract",
          certbot_domains = Some [ "flexextract.icos-cp.eu" ],
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          flexextract_src_dir = None Text,
          flexextract_download_host = None Text,
          sshlogin_dst = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text
        }
      , {
          name = None Text,
          tags = "nginx",
          role = "icos.nginxsite",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } }),
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = Some "flexextract",
          nginxsite_file = Some "files/flexextract.conf",
          flexextract_src_dir = None Text,
          flexextract_download_host = None Text,
          sshlogin_dst = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text
        }
    ]
    }
  , {
      hosts = "flexextract",
      roles = [
        {
          name = None Text,
          tags = "guest",
          role = "icos.lxd_guest",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } }),
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          flexextract_src_dir = None Text,
          flexextract_download_host = None Text,
          sshlogin_dst = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text
        }
      , {
          name = None Text,
          tags = "docker",
          role = "icos.docker",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } }),
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          flexextract_src_dir = None Text,
          flexextract_download_host = None Text,
          sshlogin_dst = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text
        }
      , {
          name = None Text,
          tags = "flexextract",
          role = "icos.flexextract",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } }),
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          flexextract_src_dir = Some "/tmp/docker_flexextract_7.1.0",
          flexextract_download_host = Some "/disk/data/flexextract_download",
          sshlogin_dst = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text
        }
      , {
          name = None Text,
          tags = "sshlogin",
          role = "icos.sshlogin",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text }),
          lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } }),
          certbot_name = None Text,
          certbot_domains = None (List Text),
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          flexextract_src_dir = None Text,
          flexextract_download_host = None Text,
          sshlogin_dst = Some "flexpart",
          sshlogin_src_user = Some "root",
          sshlogin_dst_user = Some "ubuntu"
        }
    ]
    }
]
