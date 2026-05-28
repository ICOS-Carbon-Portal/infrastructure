-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , set_fact : Optional ({ sshlogin_src_user : Text, sshlogin_dst_user : Text })
    , loop : Optional (List Text)
    , user : Optional ({ name : Text, home : Text, generate_ssh_key : Bool })
    , register : Optional Text
    , delegate_to : Optional Text
    , shellfact : Optional ({ exec : Text, fact : Text })
    , become : Optional Bool
    , become_user : Optional Text
    , block : Optional (List ({ name : Text, known_hosts : Optional ({ path : Text, name : Text, key : Text }), loop : Optional Text, blockinfile : Optional ({ marker : Text, create : Bool, path : Text, block : Text }), user : Optional ({ name : Text, home : Text }), register : Optional Text, authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }) }))
  }
    , default =
        { name = None Text
    , fail = None ({ msg : Text })
    , when = None Text
    , set_fact = None ({ sshlogin_src_user : Text, sshlogin_dst_user : Text })
    , loop = None (List Text)
    , user = None ({ name : Text, home : Text, generate_ssh_key : Bool })
    , register = None Text
    , delegate_to = None Text
    , shellfact = None ({ exec : Text, fact : Text })
    , become = None Bool
    , become_user = None Text
    , block = None (List ({ name : Text, known_hosts : Optional ({ path : Text, name : Text, key : Text }), loop : Optional Text, blockinfile : Optional ({ marker : Text, create : Bool, path : Text, block : Text }), user : Optional ({ name : Text, home : Text }), register : Optional Text, authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }) }))
  }
    }

in  [
    Item::{
      name = Some "Check that enough parameters are provided",
      fail = Some {
        msg = "Must set either sshlogin_user or both of sshlogin_src_user and sshlogin_dst_user"
    },
      when = Some ''
      not (sshlogin_user is defined or
          (sshlogin_src_user is defined and sshlogin_dst_user is defined))
    ''
    }
  , Item::{
      name = Some "Use sshlogin_user to derive sshlogin_{src,dst}_user",
      when = Some "sshlogin_user is defined",
      set_fact = Some {
        sshlogin_src_user = "{{ sshlogin_user }}"
      , sshlogin_dst_user = "{{ sshlogin_user }}"
    }
    }
  , Item::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [ "sshlogin_dst", "sshlogin_src_user", "sshlogin_dst_user" ]
    }
  , Item::{
      name = Some "Create {{ sshlogin_src_user }} user",
      user = Some {
        name = "{{ sshlogin_src_user }}"
      , home = "{{ sshlogin_src_home | default(omit) }}"
      , generate_ssh_key = True
    },
      register = Some "_src_user"
    }
  , Item::{
      name = Some "Retrieve destination host keys",
      delegate_to = Some "{{ sshlogin_dst }}",
      shellfact = Some {
        exec = "ssh-keyscan localhost | sed \"s/^localhost/{{ sshlogin_dst }}/\""
      , fact = "sshlogin_dst_host_keys"
    }
    }
  , Item::{
      become = Some True,
      become_user = Some "{{ sshlogin_src_user }}",
      block = Some [
        {
          name = "Update known_hosts",
          known_hosts = Some {
            path = "{{ sshlogin_src_known_hosts }}"
          , name = "{{ sshlogin_src_dst }}"
          , key = "{{ item }}"
        },
          loop = Some "{{ sshlogin_dst_host_keys.strip().split('\\n') }}",
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          user = None ({ name : Text, home : Text }),
          register = None Text,
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text })
        }
      , {
          name = "Add ssh config",
          known_hosts = None ({ path : Text, name : Text, key : Text }),
          loop = None Text,
          blockinfile = Some {
            marker = "# {mark} ansible / sshlogin {{ sshlogin_dst }}"
          , create = True
          , path = "{{ sshlogin_src_ssh_config }}"
          , block = ''
            Host {{ sshlogin_src_dst_name }}
              Hostname {{ sshlogin_src_dst_host }}
              Port {{ sshlogin_src_dst_port }}
              User {{ sshlogin_dst_user }}

          ''
        },
          user = None ({ name : Text, home : Text }),
          register = None Text,
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text })
        }
    ]
    }
  , Item::{
      delegate_to = Some "{{ sshlogin_dst }}",
      block = Some [
        {
          name = "Create destination user",
          known_hosts = None ({ path : Text, name : Text, key : Text }),
          loop = None Text,
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          user = Some {
            name = "{{ sshlogin_dst_user }}"
          , home = "{{ sshlogin_dst_home | default(omit) }}"
        },
          register = Some "_dst_user",
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text })
        }
      , {
          name = "Install public key",
          known_hosts = None ({ path : Text, name : Text, key : Text }),
          loop = None Text,
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          user = None ({ name : Text, home : Text }),
          register = None Text,
          authorized_key = Some {
            user = "{{ sshlogin_dst_user }}"
          , state = "present"
          , key = "{{ _src_user.ssh_public_key }}"
          , key_options = "{{ sshlogin_dst_key_options }}"
        }
        }
    ]
    }
]
