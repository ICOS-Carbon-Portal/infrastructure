-- Auto-generated from ../../../../devops/roles/icos.users/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create user",
      user = Some {
        name = "{{ item.name }}",
        uid = None Text,
        group = None Text,
        password = Some "{{ item.password | default(omit) }}",
        non_unique = None Bool,
        create_home = None Text,
        shell = None Text,
        home = Some "{{ item.home | default(omit) }}",
        password_lock = None Bool,
        groups = Some [ "{{ item.groups | default(omit) }}" ],
        append = Some "{{ item.groups | default(false) | bool }}",
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ user_conf.create_users | default([]) }}")
    }
  , Task::{
      name = Some "Install public key",
      authorized_key = Some {
        user = "{{ item.name }}",
        key = "{{ item.key }}",
        state = Some "present",
        exclusive = Some True,
        key_options = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ user_conf.create_users | default([]) }}")
    }
  , Task::{
      name = Some "Install password-less sudo rule",
      copy = Some {
        dest = "/etc/sudoers.d/{{ item.name }}",
        mode = None Text,
        content = Some ''
        {{ item.name }} ALL=(ALL) NOPASSWD: ALL

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      when = Some [ "item.sudopwless | default(false)" ],
      loop = Some (Task.Poly_loop.Str "{{ user_conf.create_users | default([]) }}")
    }
  , Task::{
      name = Some "Remove user",
      user = Some {
        name = "{{ item.name }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = None Text,
        home = None Text,
        password_lock = None Bool,
        groups = None ((List Text)),
        append = None Text,
        state = Some "absent",
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = Some "{{ item.remove | default(omit) }}"
    },
      loop = Some (Task.Poly_loop.Str "{{ user_conf.remove_users | default([]) }}")
    }
]
