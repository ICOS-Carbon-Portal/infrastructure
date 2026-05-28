-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, password : Optional Text, home : Optional Text, groups : Optional Text, append : Optional Text, remove : Optional Text, state : Optional Text })
    , loop : Text
    , authorized_key : Optional ({ user : Text, key : Text, state : Text, exclusive : Bool })
    , copy : Optional ({ dest : Text, content : Text })
    , when : Optional Text
  }
    , default =
        { user = None ({ name : Text, password : Optional Text, home : Optional Text, groups : Optional Text, append : Optional Text, remove : Optional Text, state : Optional Text })
    , authorized_key = None ({ user : Text, key : Text, state : Text, exclusive : Bool })
    , copy = None ({ dest : Text, content : Text })
    , when = None Text
  }
    }

in  [
    Task::{
      name = "Create user",
      user = Some {
        name = "{{ item.name }}"
      , password = Some "{{ item.password | default(omit) }}"
      , home = Some "{{ item.home | default(omit) }}"
      , groups = Some "{{ item.groups | default(omit) }}"
      , append = Some "{{ item.groups | default(false) | bool }}"
      , remove = None Text
      , state = None Text
    },
      loop = "{{ user_conf.create_users | default([]) }}"
    }
  , Task::{
      name = "Install public key",
      loop = "{{ user_conf.create_users | default([]) }}",
      authorized_key = Some {
        user = "{{ item.name }}"
      , key = "{{ item.key }}"
      , state = "present"
      , exclusive = True
    }
    }
  , Task::{
      name = "Install password-less sudo rule",
      loop = "{{ user_conf.create_users | default([]) }}",
      copy = Some {
        dest = "/etc/sudoers.d/{{ item.name }}"
      , content = ''
        {{ item.name }} ALL=(ALL) NOPASSWD: ALL

      ''
    },
      when = Some "item.sudopwless | default(false)"
    }
  , Task::{
      name = "Remove user",
      user = Some {
        name = "{{ item.name }}"
      , password = None Text
      , home = None Text
      , groups = None Text
      , append = None Text
      , remove = Some "{{ item.remove | default(omit) }}"
      , state = Some "absent"
    },
      loop = "{{ user_conf.remove_users | default([]) }}"
    }
]
