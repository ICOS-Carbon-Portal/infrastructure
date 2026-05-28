-- Auto-generated from lxd.yml

[
    {
      name = "LXD metrics timer"
    , include_role = { name = "icos.timer" }
    , vars = {
        timer_wdir = "{{ node_exporter_textfiles }}"
      , timer_exec = "bash -c 'lxc query /1.0/metrics | sponge lxd.prom'"
      , timer_name = "node-exporter-lxd"
      , timer_conf = "OnCalendar=*:*:00,30"
    }
  }
]
