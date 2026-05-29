-- Auto-generated from ../../devops/host_vars/fsicos2.yml

{
    iptables_ssh_port = 60022
  , lxd_vm_variant = "ext4"
  , bbclient_remotes = [ "fsicos2", "icos1" ]
  , nginx_metrics_enable = True
  , nextcloud_volume_nextcloud = "/disk/data/nextcloud"
  , flexpart_install_run = True
  , flexpart_max_parallel = 12
  , flexpart_export_output_to = "194.47.223.133(ro,no_subtree_check)"
  , icosdata_exports = ''
    /disk/data/nextcloud/data/__groupfolders/14/Data/FLUXCOM fsicos3(ro,no_root_squash,no_subtree_check)

    # CoCO2
    /disk/data/nextcloud/data/__groupfolders/32 fsicos3(ro,no_root_squash,no_subtree_check)

    # for use in jupyter
    /disk/data/cities/dataAppStorage  fsicos3(ro,no_root_squash,no_subtree_check)

    # PAUL
    /disk/data/nextcloud/data/__groupfolders/27 fsicos3(ro,no_root_squash,no_subtree_check)

    /disk/data/flexextract            fsicos3(rw,no_subtree_check)
    /disk/data/project                fsicos3(ro,no_subtree_check)
    /disk/data/flexpart/meteo         fsicos3(ro,no_subtree_check)
    /disk/data/dataAppStorage         fsicos3(ro,no_subtree_check)
    /disk/data/stiltweb               fsicos3(ro,no_subtree_check)
    /disk/data/obspack                fsicos3(ro,no_subtree_check)
    /disk/data/stilt                  fsicos3(ro,no_subtree_check)
    /disk/data/common/netcdf/dataDemo fsicos3(rw)
    /disk/data/incoming               fsicos3(rw,no_root_squash,no_subtree_check)

  ''
  , icosdata_mkdirs = [
      "/disk/data/incoming"
    , "/disk/data/stilt"
    , "/nfs/fsicos3"
    , "/nfs/with_nextcloud/jupyter_coco2"
  ]
  , icosdata_bind_mounts = let Item =
      { Type =
          { path : Text
      , src : Text
      , opts : Optional Text
    }
      , default =
          { opts = None Text
    }
      }

  in  [
      Item::{ path = "/data/stiltweb", src = "/disk/data/stiltweb", opts = Some ",ro" }
    , Item::{ path = "/incoming", src = "/disk/data/incoming" }
    , Item::{ path = "/data/project", src = "/disk/data/project" }
    , Item::{ path = "/data/dataAppStorage", src = "/disk/data/dataAppStorage", opts = Some ",ro" }
    , Item::{ path = "/data/stilt_legacy", src = "/disk/data/stilt", opts = Some ",ro" }
  ]
  , icosdata_nfs_mounts = [
      {
        path = "/nfs/with_nextcloud/jupyter_coco2"
      , src = "fsicos3.nebula:/pool/jupyter/project/coco2/jupyter"
      , opts = "ro,soft"
    }
    , { path = "/nfs/fsicos3", src = "fsicos3.nebula:/incoming", opts = "rw" }
    , {
        path = "/data/project/eurocom"
      , src = "fsicos3.nebula:/data/project/eurocom"
      , opts = "ro,soft"
    }
    , {
        path = "/data/stilt"
      , src = "fsicos3.nebula:/pool/ute/stilt/RINGO/T1.3/STILT"
      , opts = "ro,soft"
    }
    , {
        path = "/data/project/stc"
      , src = "fsicos3.nebula:/data/project/stc"
      , opts = "ro,soft"
    }
    , {
        path = "/nfs/flexextract_meteo"
      , src = "icos1.nebula:/pool/flexextract/meteo"
      , opts = "rw,soft"
    }
    , {
        path = "/data/flexpart/output"
      , src = "fsicos3.nebula:/data/flexpart/output"
      , opts = "ro,soft"
    }
  ]
}
