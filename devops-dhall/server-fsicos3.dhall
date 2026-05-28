-- Auto-generated from server-fsicos3.yml

[
    {
      hosts = "fsicos3"
    , roles = [
        { role = "icos.server", tags = "server", when = Some "not ansible_check_mode" }
      , { role = "icos.lxd_server", tags = "lxd", when = None Text }
      , { role = "icos.nginx", tags = "nginx", when = None Text }
      , { role = "icos.podman", tags = "podman", when = None Text }
      , { role = "ops.zfs", tags = "zfs", when = None Text }
    ]
  }
]
