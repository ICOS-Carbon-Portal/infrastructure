-- Auto-generated from ../devops/util-remove.yml

let Task = ./types/Task.dhall

in  [
    {
      hosts = "fsicos2"
    , vars = { nginxsite_name = "foo", lxd_vm_name = "foo" }
    , tasks = [
        Task::{
          name = Some "Remove nginx config for {{ nginxsite_name }}",
          tags = Some [ "nginx" ],
          import_role = Some (Task.Poly_import_role.Record { name = "icos.nginxsite", tasks_from = Some "remove.yml" })
        }
      , Task::{
          name = Some "Remove lxd vm {{ lxd_vm_name }}",
          tags = Some [ "lxd" ],
          import_role = Some (Task.Poly_import_role.Record { name = "icos.lxd_vm", tasks_from = Some "remove.yml" })
        }
    ]
  }
]
