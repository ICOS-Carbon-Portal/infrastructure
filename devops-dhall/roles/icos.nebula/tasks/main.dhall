-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml", tags = Some [ "nebula_install" ] }
  , Task::{
      when = Some [ "nebula_ssh_enable", "nebula_ssh_public is not defined" ],
      import_tasks = Some "ssh.yml",
      tags = Some [ "nebula_ssh", "nebula_config" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "nebula_just" ] }
  , Task::{ import_tasks = Some "ca.yml", tags = Some [ "nebula_ca" ] }
  , Task::{ import_tasks = Some "cert.yml", tags = Some [ "nebula_cert" ] }
  , Task::{ import_tasks = Some "iptables.yml", tags = Some [ "nebula_iptables" ] }
  , Task::{ import_tasks = Some "config.yml", tags = Some [ "nebula_config" ] }
  , Task::{ import_tasks = Some "service.yml", tags = Some [ "nebula_service" ] }
  , Task::{ import_tasks = Some "hosts.yml", tags = Some [ "nebula_hosts" ] }
  , Task::{
      when = Some [ "nebula_resolve_enable" ],
      import_tasks = Some "resolve.yml",
      tags = Some [ "nebula_resolve" ]
    }
  , Task::{ import_tasks = Some "test.yml", tags = Some [ "nebula_test", "nebula_resolve" ] }
]
