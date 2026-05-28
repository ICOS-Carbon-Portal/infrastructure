-- Auto-generated from flexpart_run.yml

let Item =
    { Type =
        { name : Optional Text
    , user : Optional ({ name : Text, state : Text, groups : Text, append : Bool })
    , register : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , become : Optional Bool
    , become_user : Optional Text
    , block : Optional (List ({ name : Text, file : Optional ({ path : Text, state : Text }), register : Optional Text, copy : Optional ({ src : Text, dest : Text, mode : Optional Natural }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), loop : Optional (List Text), docker_image : Optional ({ source : Text, name : Text, build : { path : Text } }), apt : Optional ({ name : Text, state : Text }), blockinfile : Optional ({ marker : Text, create : Bool, path : Text, block : Text }), command : Optional Text, when : Optional Text }))
    , template : Optional ({ src : Text, dest : Text, mode : Natural })
    , loop : Optional (List ({ src : Text, dest : Text }))
    , when : Optional Text
  }
    , default =
        { name = None Text
    , user = None ({ name : Text, state : Text, groups : Text, append : Bool })
    , register = None Text
    , file = None ({ path : Text, state : Text })
    , become = None Bool
    , become_user = None Text
    , block = None (List ({ name : Text, file : Optional ({ path : Text, state : Text }), register : Optional Text, copy : Optional ({ src : Text, dest : Text, mode : Optional Natural }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), loop : Optional (List Text), docker_image : Optional ({ source : Text, name : Text, build : { path : Text } }), apt : Optional ({ name : Text, state : Text }), blockinfile : Optional ({ marker : Text, create : Bool, path : Text, block : Text }), command : Optional Text, when : Optional Text }))
    , template = None ({ src : Text, dest : Text, mode : Natural })
    , loop = None (List ({ src : Text, dest : Text }))
    , when = None Text
  }
    }

in  [
    Item::{
      name = Some "Create flexpart user",
      user = Some {
        name = "{{ flexpart_user }}"
      , state = "present"
      , groups = "docker"
      , append = True
    },
      register = Some "_user"
    }
  , Item::{
      name = Some "Create the flexpart output directory",
      file = Some { path = "{{ flexpart_output_directory }}", state = "directory" }
    }
  , Item::{
      become = Some True,
      become_user = Some "{{ flexpart_user }}",
      block = Some [
        {
          name = "Create flexpart build dir",
          file = Some { path = "{{ _user.home }}/build", state = "directory" },
          register = Some "_build",
          copy = None ({ src : Text, dest : Text, mode : Optional Natural }),
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          loop = None (List Text),
          docker_image = None ({ source : Text, name : Text, build : { path : Text } }),
          apt = None ({ name : Text, state : Text }),
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          command = None Text,
          when = None Text
        }
      , {
          name = "Install the flexpart ssh script",
          file = None ({ path : Text, state : Text }),
          register = None Text,
          copy = Some {
            src = "flexpart_ssh.sh"
          , dest = "{{ _user.home }}/flexpart_ssh.sh"
          , mode = Some 493
        },
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          loop = None (List Text),
          docker_image = None ({ source : Text, name : Text, build : { path : Text } }),
          apt = None ({ name : Text, state : Text }),
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          command = None Text,
          when = None Text
        }
      , {
          name = "Authorize our own ssh key",
          file = None ({ path : Text, state : Text }),
          register = None Text,
          copy = None ({ src : Text, dest : Text, mode : Optional Natural }),
          authorized_key = Some {
            user = "{{ flexpart_user }}"
          , state = "present"
          , key = "{{ lookup('file', 'roles/icos.flexpart/files/flexpart.pub') }}"
          , key_options = "command=\"{{ _user.home }}/flexpart_ssh.sh\""
        },
          loop = None (List Text),
          docker_image = None ({ source : Text, name : Text, build : { path : Text } }),
          apt = None ({ name : Text, state : Text }),
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          command = None Text,
          when = None Text
        }
      , {
          name = "Install Dockerfile and build resources",
          file = None ({ path : Text, state : Text }),
          register = Some "_resources",
          copy = Some { src = "{{ item }}", dest = "{{ _build.path }}", mode = None Natural },
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          loop = Some [
            "Dockerfile"
          , "flexpart10.2.tar.gz"
          , "flextraset.lpr"
          , "flexpart.diff"
          , "entrypoint.sh"
          , "candidate_sites.txt"
          , "grib_api.tgz"
          , "options.tgz"
        ],
          docker_image = None ({ source : Text, name : Text, build : { path : Text } }),
          apt = None ({ name : Text, state : Text }),
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          command = None Text,
          when = None Text
        }
      , {
          name = "Build flexpart image",
          file = None ({ path : Text, state : Text }),
          register = None Text,
          copy = None ({ src : Text, dest : Text, mode : Optional Natural }),
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          loop = None (List Text),
          docker_image = Some {
            source = "build"
          , name = "{{ flexpart_image }}"
          , build = { path = "{{ _build.path }}" }
        },
          apt = None ({ name : Text, state : Text }),
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          command = None Text,
          when = None Text
        }
    ]
    }
  , Item::{
      name = Some "Install the flexpart shell scripts",
      template = Some { src = "{{ item.src }}", dest = "{{ item.dest }}", mode = 493 },
      loop = Some [
        { src = "flexpart.sh.j2", dest = "/usr/local/bin/flexpart" }
      , { src = "flexpart_run.sh.j2", dest = "/usr/local/bin/flexpart_run" }
    ]
    }
  , Item::{
      block = Some [
        {
          name = "Install ssh server",
          file = None ({ path : Text, state : Text }),
          register = None Text,
          copy = None ({ src : Text, dest : Text, mode : Optional Natural }),
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          loop = None (List Text),
          docker_image = None ({ source : Text, name : Text, build : { path : Text } }),
          apt = Some { name = "nfs-kernel-server", state = "present" },
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          command = None Text,
          when = None Text
        }
      , {
          name = "Export flexpart output data via nfs",
          file = None ({ path : Text, state : Text }),
          register = Some "_export",
          copy = None ({ src : Text, dest : Text, mode : Optional Natural }),
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          loop = None (List Text),
          docker_image = None ({ source : Text, name : Text, build : { path : Text } }),
          apt = None ({ name : Text, state : Text }),
          blockinfile = Some {
            marker = "# {mark} ansible/flexpart"
          , create = True
          , path = "/etc/exports"
          , block = ''
            {{ flexpart_output_directory }} {{ flexpart_export_output_to }}

          ''
        },
          command = None Text,
          when = None Text
        }
      , {
          name = "Re-export filesystems",
          file = None ({ path : Text, state : Text }),
          register = None Text,
          copy = None ({ src : Text, dest : Text, mode : Optional Natural }),
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          loop = None (List Text),
          docker_image = None ({ source : Text, name : Text, build : { path : Text } }),
          apt = None ({ name : Text, state : Text }),
          blockinfile = None ({ marker : Text, create : Bool, path : Text, block : Text }),
          command = Some "/usr/sbin/exportfs -ra",
          when = Some "_export.changed"
        }
    ],
      when = Some "flexpart_export_output_to != \"\""
    }
]
