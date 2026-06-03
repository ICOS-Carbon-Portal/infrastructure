import { type Playbook, role, tmpl, V } from "../lib/ansible.ts";

export default [
  {
    hosts: "cdb",
    roles: [
      role("icos.docker2").tags("docker"),
      role("icos.victoriametrics", {
        vm_graf_domain: "graf.icos-cp.eu",
        vm_graf_pass: V.vault_vm_graf_pass,
        vm_promlens_token: V.vault_prometheus_promlens_token,
      }).tags("prom"),
      role("icos.caddy", {
        caddy_name: "prometheus",
        caddy_conf: `# SNIPPET
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
`,
      }).tags("caddy"),
    ],
    tasks: [
      {
        name: "Show basic auth for prometheus",
        tags: "showauth",
        debug: {
          msg:
            tmpl`Basic auth for prometheus is ${V.vault_vmagent_auth.username}/${V.vault_vmagent_auth.password}`,
        },
      },
    ],
  },
] satisfies Playbook;
