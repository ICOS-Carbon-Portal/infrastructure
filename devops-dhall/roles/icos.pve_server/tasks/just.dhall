-- Auto-generated from ../../../../devops/roles/icos.pve_server/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy ops-proxmox-server",
      copy = Some {
        dest = "/usr/local/bin/",
        mode = Some "+x",
        content = None Text,
        src = Some "ops-proxmox-server",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_ops"
    }
  , Task::{
      name = Some "Check that the justfile is executable",
      shell = Some "{{ _ops.dest }}",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Add alias for ops-proxmox-server",
      lineinfile = Some {
        path = "/root/.bashrc",
        regex = Some "^alias [^=]+=ops-proxmox-server",
        line = Some "alias px=ops-proxmox-server",
        state = None Text,
        backrefs = None Bool,
        regexp = None Text,
        create = Some False,
        owner = None Text,
        group = None Text,
        insertafter = Some "EOF",
        mode = None Natural,
        insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Check that alias and justfile works",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str "px"),
      args = Some {
        chdir = None Text,
        creates = None Text,
        executable = Some "/bin/bash",
        removes = None Text
    },
      changed_when = Some (Task.Poly_changed_when.Bool False),
      register = Some "_r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "\"onboot\" in _r.stdout" ])
    }
]
