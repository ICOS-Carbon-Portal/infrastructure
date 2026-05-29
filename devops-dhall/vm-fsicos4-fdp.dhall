-- Auto-generated from ../devops/vm-fsicos4-fdp.yml

[
    {
      hosts = "fsicos4",
      roles = [
        {
          role = "icos.caddy",
          tags = "caddy",
          caddy_name = Some "fdpdemo",
          caddy_conf = Some ''
          fdpdemo.envri.eu {
              reverse_proxy 10.10.10.236:80
          }

        ''
        }
    ]
    }
  , {
      hosts = "fdp",
      roles = [
        {
          role = "icos.fairdatapoint",
          tags = "fairdatapoint",
          caddy_name = None Text,
          caddy_conf = None Text
        }
    ]
    }
]
