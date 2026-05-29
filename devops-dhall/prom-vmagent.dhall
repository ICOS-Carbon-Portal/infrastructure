-- Auto-generated from ../devops/prom-vmagent.yml

[
    {
      hosts = "vmagent_hosts"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , sexp_exporters : Optional (List Text)
      }
        , default =
            { sexp_exporters = None (List Text)
      }
        }

    in  [
        Role::{ role = "icos.vmagent", tags = "vmagent" }
      , Role::{ role = "icos.node_exporter", tags = "node" }
      , Role::{ role = "icos.script_exporter", tags = "script", sexp_exporters = Some [ "smartmon" ] }
    ]
  }
]
