-- Auto-generated from ../devops/vm-flexextract.yml

[
    {
      hosts = "fsicos2",
      roles = let Role =
        { Type =
            { name : Optional Text
        , tags : Text
        , role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_docker : Optional Bool
        , lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text })
        , lxd_vm_devices : Optional ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } })
        , certbot_name : Optional Text
        , certbot_domains : Optional (List Text)
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , flexextract_src_dir : Optional Text
        , flexextract_download_host : Optional Text
        , sshlogin_dst : Optional Text
        , sshlogin_src_user : Optional Text
        , sshlogin_dst_user : Optional Text
      }
        , default =
            { name = None Text
        , lxd_vm_name = None Text
        , lxd_vm_docker = None Bool
        , lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text })
        , lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } })
        , certbot_name = None Text
        , certbot_domains = None (List Text)
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , flexextract_src_dir = None Text
        , flexextract_download_host = None Text
        , sshlogin_dst = None Text
        , sshlogin_src_user = None Text
        , sshlogin_dst_user = None Text
      }
        }

    in  [
        Role::{
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
        }
        }
      , Role::{
          tags = "cert",
          role = "icos.certbot2",
          certbot_name = Some "flexextract",
          certbot_domains = Some [ "flexextract.icos-cp.eu" ]
        }
      , Role::{
          tags = "nginx",
          role = "icos.nginxsite",
          nginxsite_name = Some "flexextract",
          nginxsite_file = Some "files/flexextract.conf"
        }
    ]
    }
  , {
      hosts = "flexextract",
      roles = let Role =
        { Type =
            { name : Optional Text
        , tags : Text
        , role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_docker : Optional Bool
        , lxd_vm_config : Optional ({ `limits.cpu` : Text, `limits.memory` : Text })
        , lxd_vm_devices : Optional ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } })
        , certbot_name : Optional Text
        , certbot_domains : Optional (List Text)
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , flexextract_src_dir : Optional Text
        , flexextract_download_host : Optional Text
        , sshlogin_dst : Optional Text
        , sshlogin_src_user : Optional Text
        , sshlogin_dst_user : Optional Text
      }
        , default =
            { name = None Text
        , lxd_vm_name = None Text
        , lxd_vm_docker = None Bool
        , lxd_vm_config = None ({ `limits.cpu` : Text, `limits.memory` : Text })
        , lxd_vm_devices = None ({ flexextract : { path : Text, source : Text, type : Text, recursive : Text }, flexextract_meteo : { path : Text, source : Text, type : Text }, flexpart_output : { path : Text, source : Text, type : Text, readonly : Text } })
        , certbot_name = None Text
        , certbot_domains = None (List Text)
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , flexextract_src_dir = None Text
        , flexextract_download_host = None Text
        , sshlogin_dst = None Text
        , sshlogin_src_user = None Text
        , sshlogin_dst_user = None Text
      }
        }

    in  [
        Role::{ tags = "guest", role = "icos.lxd_guest" }
      , Role::{ tags = "docker", role = "icos.docker" }
      , Role::{
          tags = "flexextract",
          role = "icos.flexextract",
          flexextract_src_dir = Some "/tmp/docker_flexextract_7.1.0",
          flexextract_download_host = Some "/disk/data/flexextract_download"
        }
      , Role::{
          tags = "sshlogin",
          role = "icos.sshlogin",
          sshlogin_dst = Some "flexpart",
          sshlogin_src_user = Some "root",
          sshlogin_dst_user = Some "ubuntu"
        }
    ]
    }
]
