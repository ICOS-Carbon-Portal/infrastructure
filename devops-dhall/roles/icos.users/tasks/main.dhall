-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create user",
      user = Some {
        name = "{{ item.name }}"
      , home = Some "{{ item.home | default(omit) }}"
      , create_home = None Text
      , shell = None Text
      , groups = Some [ "{{ item.groups | default(omit) }}" ]
      , append = Some "{{ item.groups | default(false) | bool }}"
      , state = None Text
      , system = None Bool
      , password = Some "{{ item.password | default(omit) }}"
      , generate_ssh_key = None Bool
      , remove = None Text
    },
      loop = Some [ "{{ user_conf.create_users | default([]) }}" ]
    }
  , Task::{
      name = Some "Install public key",
      authorized_key = Some {
        user = "{{ item.name }}"
      , key_options = None Text
      , key = "{{ item.key }}"
      , state = Some "present"
      , exclusive = Some True
    },
      loop = Some [ "{{ user_conf.create_users | default([]) }}" ]
    }
  , Task::{
      name = Some "Install password-less sudo rule",
      copy = Some {
        src = None Text
      , dest = "/etc/sudoers.d/{{ item.name }}"
      , mode = None Text
      , content = Some ''
        {{ item.name }} ALL=(ALL) NOPASSWD: ALL

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      when = Some [ "item.sudopwless | default(false)" ],
      loop = Some [ "{{ user_conf.create_users | default([]) }}" ]
    }
  , Task::{
      name = Some "Remove user",
      user = Some {
        name = "{{ item.name }}"
      , home = None Text
      , create_home = None Text
      , shell = None Text
      , groups = None (List Text)
      , append = None Text
      , state = Some "absent"
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = Some "{{ item.remove | default(omit) }}"
    },
      loop = Some [ "{{ user_conf.remove_users | default([]) }}" ]
    }
]
