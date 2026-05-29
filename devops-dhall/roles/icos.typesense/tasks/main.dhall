-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , include_vars : Optional Text
    , tags : List Text
    , block : Optional (List ({ name : Optional Text, user : Optional ({ name : Text, state : Text }), file : Optional ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }), template : Optional ({ src : Text, dest : Text, owner : Text }), `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }), fail : Optional ({ msg : Text }), when : Optional Text, `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text }), loop : Optional (List ({ src : Text })), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), `ansible.builtin.shell` : Optional Text, args : Optional ({ chdir : Text }) }))
  }
    , default =
        { include_vars = None Text
    , block = None (List ({ name : Optional Text, user : Optional ({ name : Text, state : Text }), file : Optional ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }), template : Optional ({ src : Text, dest : Text, owner : Text }), `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }), fail : Optional ({ msg : Text }), when : Optional Text, `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text }), loop : Optional (List ({ src : Text })), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), `ansible.builtin.shell` : Optional Text, args : Optional ({ chdir : Text }) }))
  }
    }

in  [
    Entry::{
      name = "Include vars",
      include_vars = Some "vault.yml",
      tags = [
        "setup"
      , "initialize_collection"
      , "update_synonyms"
      , "update_documents"
      , "timer"
    ]
    }
  , Entry::{
      name = "Set up typesense service",
      tags = [ "setup" ],
      block = Some [
        {
          name = Some "Create user",
          user = Some { name = "{{ typesense_user }}", state = "present" },
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Create {{ typesense_home }}/docker/ directory",
          user = None ({ name : Text, state : Text }),
          file = Some {
            path = "{{ typesense_home }}/docker/"
          , state = "directory"
          , recurse = Some True
          , owner = "{{ typesense_user }}"
          , mode = None Text
          , modification_time = None Text
          , access_time = None Text
        },
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Create {{ typesense_home }}/data/ directory",
          user = None ({ name : Text, state : Text }),
          file = Some {
            path = "{{ typesense_home }}/data/"
          , state = "directory"
          , recurse = Some True
          , owner = "{{ typesense_user }}"
          , mode = None Text
          , modification_time = None Text
          , access_time = None Text
        },
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Create {{ typesense_home }}/analytics/ directory",
          user = None ({ name : Text, state : Text }),
          file = Some {
            path = "{{ typesense_home }}/analytics/"
          , state = "directory"
          , recurse = Some True
          , owner = "{{ typesense_user }}"
          , mode = None Text
          , modification_time = None Text
          , access_time = None Text
        },
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Copy docker-compose.yml",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = Some {
            src = "docker-compose.yml"
          , dest = "{{ typesense_home }}/docker/docker-compose.yml"
          , owner = "{{ typesense_user }}"
        },
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "(Re)start docker containers",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = Some { project_src = "{{ typesense_home }}/docker", state = "present", pull = "always" },
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = None Text,
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = Some { name = "icos.nginxsite" },
          vars = Some {
            nginxsite_name = Some "typesense"
          , nginxsite_file = Some "typesense-nginx.conf"
          , nginxsite_domains = Some [ "typesense.icos-cp.eu" ]
          , timer_user = None Text
          , timer_home = None Text
          , timer_name = None Text
          , timer_conf = None Text
          , timer_content = None Text
        },
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
    ]
    }
  , Entry::{
      name = "Check that website is defined and valid",
      tags = [ "initialize_collection", "update_synonyms", "update_documents", "timer" ],
      block = Some [
        {
          name = Some "Check if website is defined",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = Some { msg = "website needs to be defined" },
          when = Some "website is undefined",
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Check that website is valid",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = Some { msg = "website provided is not valid" },
          when = Some "website not in base_urls",
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
    ]
    }
  , Entry::{
      name = "Create and initialize collection",
      tags = [ "initialize_collection" ],
      block = Some [
        {
          name = Some "Create {{ website }} directory",
          user = None ({ name : Text, state : Text }),
          file = Some {
            path = "{{ typesense_home }}/{{ website }}/"
          , state = "directory"
          , recurse = Some True
          , owner = "{{ typesense_user }}"
          , mode = None Text
          , modification_time = None Text
          , access_time = None Text
        },
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Copy requirements.txt to {{ typesense_home }}",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = Some {
            src = "requirements.txt"
          , dest = "{{ typesense_home }}/requirements.txt"
          , owner = Some "{{ typesense_user }}"
        },
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Create log file in {{ typesense_home }}/{{ website }}",
          user = None ({ name : Text, state : Text }),
          file = Some {
            path = "{{ typesense_home }}/{{ website }}/collection.log"
          , state = "touch"
          , recurse = None Bool
          , owner = "{{ typesense_user }}"
          , mode = Some "u+rw,g-wx,o-rwx"
          , modification_time = Some "preserve"
          , access_time = Some "preserve"
        },
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Set up logrotate for typesense website {{ website }}",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = Some {
            src = "logrotate"
          , dest = "/etc/logrotate.d/typesense-{{ website }}"
          , owner = None Text
        },
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Copy python scripts and schema to {{ website }} directory",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = Some {
            src = "{{ item.src }}"
          , dest = "{{ typesense_home }}/{{ website }}"
          , owner = Some "{{ typesense_user }}"
        },
          loop = Some [
            { src = "schema.yml" }
          , { src = "init_collection.py" }
          , { src = "init_documents.py" }
          , { src = "update_documents.py" }
          , { src = "update_stations.py" }
          , { src = "utilities.py" }
        ],
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Install required modules into Python virtual environment",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = Some {
            virtualenv = "{{ typesense_home }}/typesense-venv"
          , virtualenv_command = "python3 -m venv"
          , requirements = "{{ typesense_home }}/requirements.txt"
        },
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Create collection",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = Some ''
          {{ typesense_home }}/typesense-venv/bin/python3 {{ typesense_home }}/{{ website }}/init_collection.py >> collection.log 2>&1

        '',
          args = Some { chdir = "{{ typesense_home }}/{{ website }}" }
        }
      , {
          name = Some "Add initial documents to collection",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = Some ''
          {{ typesense_home }}/typesense-venv/bin/python3 {{ typesense_home }}/{{ website }}/init_documents.py >> collection.log 2>&1

        '',
          args = Some { chdir = "{{ typesense_home }}/{{ website }}" }
        }
      , {
          name = Some "Add initial stations to collection",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = Some ''
          {{ typesense_home }}/typesense-venv/bin/python3 {{ typesense_home }}/{{ website }}/update_stations.py >> collection.log 2>&1

        '',
          args = Some { chdir = "{{ typesense_home }}/{{ website }}" }
        }
    ]
    }
  , Entry::{
      name = "Add timer for updating documents and stations",
      tags = [ "initialize_collection", "timer" ],
      block = Some [
        {
          name = Some "Install typesense-update-{{ website }} timer",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = Some { name = "icos.timer" },
          vars = Some {
            nginxsite_name = None Text
          , nginxsite_file = None Text
          , nginxsite_domains = None (List Text)
          , timer_user = Some "{{ typesense_user }}"
          , timer_home = Some "{{ typesense_home }}"
          , timer_name = Some "typesense-update-{{ website }}"
          , timer_conf = Some ''
            OnCalendar=*-*-* 1/4:17:00

          ''
          , timer_content = Some ''
            #!/bin/bash
            cd {{ typesense_home }}/{{ website }}
            {{ typesense_home }}/typesense-venv/bin/python3 update_documents.py >> collection.log 2>&1
            {{ typesense_home }}/typesense-venv/bin/python3 update_stations.py >> collection.log 2>&1

          ''
        },
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
    ]
    }
  , Entry::{
      name = "Update synonyms",
      tags = [ "update_synonyms", "initialize_collection" ],
      block = Some [
        {
          name = Some "Copy update_synonyms required python scripts to {{ website }} directory",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = Some {
            src = "{{ item.src }}"
          , dest = "{{ typesense_home }}/{{ website }}"
          , owner = Some "{{ typesense_user }}"
        },
          loop = Some [
            { src = "update_synonyms.py" }
          , { src = "utilities.py" }
        ],
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Run update synonyms script",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = Some ''
          {{ typesense_home }}/typesense-venv/bin/python3 {{ typesense_home }}/{{ website }}/update_synonyms.py >> collection.log 2>&1

        '',
          args = Some { chdir = "{{ typesense_home }}/{{ website }}" }
        }
    ]
    }
  , Entry::{
      name = "Update documents and stations without reinitializing collection",
      tags = [ "update_documents" ],
      block = Some [
        {
          name = Some "Copy python scripts to {{ website }} directory",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = Some {
            src = "{{ item.src }}"
          , dest = "{{ typesense_home }}/{{ website }}"
          , owner = Some "{{ typesense_user }}"
        },
          loop = Some [
            { src = "update_documents.py" }
          , { src = "update_stations.py" }
          , { src = "utilities.py" }
        ],
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text })
        }
      , {
          name = Some "Run update documents script",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = Some ''
          {{ typesense_home }}/typesense-venv/bin/python3 {{ typesense_home }}/{{ website }}/update_documents.py >> collection.log 2>&1

        '',
          args = Some { chdir = "{{ typesense_home }}/{{ website }}" }
        }
      , {
          name = Some "Run update stations script",
          user = None ({ name : Text, state : Text }),
          file = None ({ path : Text, state : Text, recurse : Optional Bool, owner : Text, mode : Optional Text, modification_time : Optional Text, access_time : Optional Text }),
          template = None ({ src : Text, dest : Text, owner : Text }),
          `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text }),
          include_role = None ({ name : Text }),
          vars = None ({ nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text), timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text }),
          fail = None ({ msg : Text }),
          when = None Text,
          `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text }),
          loop = None (List ({ src : Text })),
          `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }),
          `ansible.builtin.shell` = Some ''
          {{ typesense_home }}/typesense-venv/bin/python3 {{ typesense_home }}/{{ website }}/update_stations.py >> collection.log 2>&1

        '',
          args = Some { chdir = "{{ typesense_home }}/{{ website }}" }
        }
    ]
    }
]
