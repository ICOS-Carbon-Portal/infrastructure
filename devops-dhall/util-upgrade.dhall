-- Auto-generated from ../devops/util-upgrade.yml

[
    {
      hosts = "all",
      tasks = let Item =
        { Type =
            { group_by : Optional ({ key : Text })
        , debug : Optional Text
        , name : Optional Text
        , dpkg_selections : Optional ({ name : Text, selection : Text })
        , loop : Optional (List Text)
        , apt : Optional ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot : Optional Text
        , command : Optional Text
      }
        , default =
            { group_by = None ({ key : Text })
        , debug = None Text
        , name = None Text
        , dpkg_selections = None ({ name : Text, selection : Text })
        , loop = None (List Text)
        , apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot = None Text
        , command = None Text
      }
        }

    in  [
        Item::{ group_by = Some { key = "{{ ansible_distribution_release }}_hosts" } }
    ]
    }
  , {
      hosts = "focal_hosts",
      tasks = let Item =
        { Type =
            { group_by : Optional ({ key : Text })
        , debug : Optional Text
        , name : Optional Text
        , dpkg_selections : Optional ({ name : Text, selection : Text })
        , loop : Optional (List Text)
        , apt : Optional ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot : Optional Text
        , command : Optional Text
      }
        , default =
            { group_by = None ({ key : Text })
        , debug = None Text
        , name = None Text
        , dpkg_selections = None ({ name : Text, selection : Text })
        , loop = None (List Text)
        , apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot = None Text
        , command = None Text
      }
        }

    in  [
        Item::{ debug = Some "var=inventory_hostname" }
      , Item::{ debug = Some "var=docker_prevent_upgrade" }
    ]
    }
  , {
      hosts = "focal_hosts",
      tasks = let Task =
        { Type =
            { group_by : Optional ({ key : Text })
        , debug : Optional Text
        , name : Optional Text
        , dpkg_selections : Optional ({ name : Text, selection : Text })
        , loop : Optional (List Text)
        , apt : Optional ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot : Optional Text
        , command : Optional Text
      }
        , default =
            { group_by = None ({ key : Text })
        , debug = None Text
        , name = None Text
        , dpkg_selections = None ({ name : Text, selection : Text })
        , loop = None (List Text)
        , apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot = None Text
        , command = None Text
      }
        }

    in  [
        Task::{
          name = Some "Make sure docker is upgraded",
          dpkg_selections = Some { name = "{{ item }}", selection = "install" },
          loop = Some [ "docker.io", "containerd" ]
        }
      , Task::{
          name = Some "upgrade everything",
          apt = Some { update_cache = Some True, upgrade = Some "full", name = None (List Text) }
        }
      , Task::{ name = Some "reboot" }
      , Task::{
          name = Some "Install ubuntu-release-upgrader-core",
          apt = Some {
            update_cache = None Bool
          , upgrade = None Text
          , name = Some [ "ubuntu-release-upgrader-core" ]
        }
        }
      , Task::{
          name = Some "release upgrade",
          command = Some "do-release-upgrade -f DistUpgradeViewNonInteractive"
        }
      , Task::{ name = Some "reboot" }
    ]
    }
  , {
      hosts = "jammy_hosts",
      tasks = let Entry =
        { Type =
            { group_by : Optional ({ key : Text })
        , debug : Optional Text
        , name : Optional Text
        , dpkg_selections : Optional ({ name : Text, selection : Text })
        , loop : Optional (List Text)
        , apt : Optional ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot : Optional Text
        , command : Optional Text
      }
        , default =
            { group_by = None ({ key : Text })
        , debug = None Text
        , name = None Text
        , dpkg_selections = None ({ name : Text, selection : Text })
        , loop = None (List Text)
        , apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) })
        , reboot = None Text
        , command = None Text
      }
        }

    in  [
        Entry::{
          name = Some "Make sure docker isn't upgraded",
          dpkg_selections = Some {
            name = "{{ item }}"
          , selection = "{{ 'hold' if docker_prevent_upgrade | default(false) else 'install' }}"
        },
          loop = Some [ "docker.io", "containerd" ]
        }
    ]
    }
]
