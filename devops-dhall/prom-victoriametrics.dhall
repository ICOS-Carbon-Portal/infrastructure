-- Auto-generated from ../devops/prom-victoriametrics.yml

let Task = ./types/Task.dhall

in  [
    {
      hosts = "cdb"
    , roles = [
        {
          role = "icos.docker2",
          tags = "docker",
          vm_graf_domain = None Text,
          vm_graf_pass = None Text,
          vm_promlens_token = None Text,
          caddy_name = None Text,
          caddy_conf = None Text
        }
      , {
          role = "icos.victoriametrics",
          tags = "prom",
          vm_graf_domain = Some "graf.icos-cp.eu",
          vm_graf_pass = Some "{{ vault_vm_graf_pass }}",
          vm_promlens_token = Some "{{ vault_prometheus_promlens_token }}",
          caddy_name = None Text,
          caddy_conf = None Text
        }
      , {
          role = "icos.caddy",
          tags = "caddy",
          vm_graf_domain = None Text,
          vm_graf_pass = None Text,
          vm_promlens_token = None Text,
          caddy_name = Some "prometheus",
          caddy_conf = Some ''
          # SNIPPET
          (icosip) {
              remote_ip 130.235.74.215  # icos1
              remote_ip 130.235.74.216  # icos1
              remote_ip 130.235.74.217  # icos1
              remote_ip 130.235.74.218  # icos1
              remote_ip 194.47.223.139  # fsicos2
              remote_ip 194.47.223.137  # fsicos3
              remote_ip 130.235.99.237  # cdb
          }

          (prometheus_auth) {
            basicauth bcrypt prometheus {
              {{ vault_vmagent_auth.username }} "{{
                vault_vmagent_auth.password |
                password_hash('bcrypt', vault_bcrypt_salt) }}"
            }
          }

          # PROMLENS
          lens.icos-cp.eu {
            import prometheus_auth
            reverse_proxy localhost:{{ vm_promlens_port }}
          }

          # GRAFANA
          graf.icos-cp.eu {
            # no basic auth for grafana, it has its own auth.
            reverse_proxy localhost:3000
          }

          # PROMETHEUS
          prom.icos-cp.eu {
            import prometheus_auth

            @api_not_icos {
              path /api/*
              not {
                import icosip
              }
            }

            respond @api_not_icos 401
            reverse_proxy localhost:{{ vm_vm_port }}
          }

        ''
        }
    ]
    , tasks = [
        Task::{
          name = Some "Show basic auth for prometheus",
          tags = Some [ "showauth" ],
          debug = Some (Task.Poly_debug.Record {
              msg = "Basic auth for prometheus is {{ vault_vmagent_auth.username }}/{{ vault_vmagent_auth.password }}"
          })
        }
    ]
  }
]
