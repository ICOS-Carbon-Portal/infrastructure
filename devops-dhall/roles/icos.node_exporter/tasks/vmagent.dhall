-- Auto-generated from vmagent.yml

let Entry =
    { Type =
        { name : Text
    , tags : Optional Text
    , shellfact : Optional ({ exec : Text, fact : Text, list : Bool })
    , include_role : Optional ({ name : Text, tasks_from : Text })
    , vars : Optional ({ vmagent_config_dest : Text, vmagent_config_content : Text })
  }
    , default =
        { tags = None Text
    , shellfact = None ({ exec : Text, fact : Text, list : Bool })
    , include_role = None ({ name : Text, tasks_from : Text })
    , vars = None ({ vmagent_config_dest : Text, vmagent_config_content : Text })
  }
    }

in  [
    Entry::{
      name = "Retrieve bindmounts fact",
      tags = Some "conf",
      shellfact = Some {
        exec = "awk '$4 ~ /bind/ { print $2 }' /etc/fstab"
      , fact = "bindmounts"
      , list = True
    }
    }
  , Entry::{
      name = "Add ourselves to the local vmagent installation",
      include_role = Some { name = "icos.vmagent", tasks_from = "add_config" },
      vars = Some {
        vmagent_config_dest = "node-exporter-host.yaml"
      , vmagent_config_content = ''
        # The node exporter on host
        - job_name: node-exporter
          static_configs:
          - targets:
            - localhost:{{ node_exporter_listen }}
            labels:
              instance: {{ inventory_hostname_short }}
          metric_relabel_configs:
            # drop irrelevant filesystems
            - source_labels: [fstype]
              regex:
                - nfs4
                - tmpfs
                - fuse
              action: drop

            # drop bindmounts
            - source_labels: [mountpoint]
              # victoriametrics has an enhancement to the regex field, it can
              # be a list of strings that are then joined using '|'
              regex:
                - {{ bindmounts }}
              action: drop

      ''
    }
    }
]
