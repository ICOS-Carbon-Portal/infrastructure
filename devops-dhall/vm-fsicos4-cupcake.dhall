-- Auto-generated from ../devops/vm-fsicos4-cupcake.yml

[
    {
      hosts = "cupcake"
    , roles = [
        { role = "icos.pve_guest", tags = "guest" }
      , { role = "icos.utils", tags = "utils" }
      , { role = "icos.python3", tags = "python3" }
      , { role = "icos.docker2", tags = "docker" }
    ]
  }
]
