-- Auto-generated from sysctl.yml

[
    {
      name = "Set sysctl value"
    , sysctl = { name = "{{ item.name }}", value = "{{ item.value }}" }
    , loop = [
        { name = "fs.aio-max-nr", value = 524288 }
      , { name = "fs.inotify.max_queued_events", value = 1048576 }
      , { name = "fs.inotify.max_user_instances", value = 1048576 }
      , { name = "fs.inotify.max_user_watches", value = 1048576 }
      , { name = "kernel.keys.maxbytes", value = 100000 }
      , { name = "kernel.keys.maxkeys", value = 4000 }
      , { name = "net.ipv4.neigh.default.gc_thresh3", value = 8192 }
      , { name = "net.ipv6.neigh.default.gc_thresh3", value = 8192 }
      , { name = "vm.max_map_count", value = 262144 }
      , { name = "kernel.dmesg_restrict", value = 1 }
      , { name = "net.core.netdev_max_backlog", value = 300000 }
    ]
  }
]
