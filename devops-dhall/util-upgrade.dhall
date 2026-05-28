-- Auto-generated from util-upgrade.yml

[
    {
      hosts = "all",
      tasks = [
        {
          group_by = Some { key = "{{ ansible_distribution_release }}_hosts" },
          debug = None Text,
          name = None Text,
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = None Text
        }
    ]
    }
  , {
      hosts = "focal_hosts",
      tasks = [
        {
          group_by = None ({ key : Text }),
          debug = Some "var=inventory_hostname",
          name = None Text,
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = None Text
        }
      , {
          group_by = None ({ key : Text }),
          debug = Some "var=docker_prevent_upgrade",
          name = None Text,
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = None Text
        }
    ]
    }
  , {
      hosts = "focal_hosts",
      tasks = [
        {
          group_by = None ({ key : Text }),
          debug = None Text,
          name = Some "Make sure docker is upgraded",
          dpkg_selections = Some { name = "{{ item }}", selection = "install" },
          loop = Some [ "docker.io", "containerd" ],
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = None Text
        }
      , {
          group_by = None ({ key : Text }),
          debug = None Text,
          name = Some "upgrade everything",
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = Some { update_cache = Some True, upgrade = Some "full", name = None (List Text) },
          reboot = None Text,
          command = None Text
        }
      , {
          group_by = None ({ key : Text }),
          debug = None Text,
          name = Some "reboot",
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = None Text
        }
      , {
          group_by = None ({ key : Text }),
          debug = None Text,
          name = Some "Install ubuntu-release-upgrader-core",
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = Some {
            update_cache = None Bool
          , upgrade = None Text
          , name = Some [ "ubuntu-release-upgrader-core" ]
        },
          reboot = None Text,
          command = None Text
        }
      , {
          group_by = None ({ key : Text }),
          debug = None Text,
          name = Some "release upgrade",
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = Some "do-release-upgrade -f DistUpgradeViewNonInteractive"
        }
      , {
          group_by = None ({ key : Text }),
          debug = None Text,
          name = Some "reboot",
          dpkg_selections = None ({ name : Text, selection : Text }),
          loop = None (List Text),
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = None Text
        }
    ]
    }
  , {
      hosts = "jammy_hosts",
      tasks = [
        {
          group_by = None ({ key : Text }),
          debug = None Text,
          name = Some "Make sure docker isn't upgraded",
          dpkg_selections = Some {
            name = "{{ item }}"
          , selection = "{{ 'hold' if docker_prevent_upgrade | default(false) else 'install' }}"
        },
          loop = Some [ "docker.io", "containerd" ],
          apt = None ({ update_cache : Optional Bool, upgrade : Optional Text, name : Optional (List Text) }),
          reboot = None Text,
          command = None Text
        }
    ]
    }
]
