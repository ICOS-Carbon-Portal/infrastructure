-- Auto-generated from prom-vmagent.yml

[
    {
      hosts = "vmagent_hosts"
    , roles = [
        { role = "icos.vmagent", tags = "vmagent", sexp_exporters = None (List Text) }
      , { role = "icos.node_exporter", tags = "node", sexp_exporters = None (List Text) }
      , { role = "icos.script_exporter", tags = "script", sexp_exporters = Some [ "smartmon" ] }
    ]
  }
]
