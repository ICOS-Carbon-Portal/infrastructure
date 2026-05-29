-- Auto-generated from ../../../../devops/roles/icos.geoip/tasks/geoip_setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create geoip user",
      user = Some {
        name = "{{ geoip_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = Some "False",
        shell = None Text,
        home = Some "{{ geoip_home }}",
        password_lock = None Bool,
        groups = None ((List Text)),
        append = None Text,
        state = Some "present",
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    },
      register = Some "_user"
    }
  , Task::{
      name = Some "Create build directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ geoip_build_dir }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Create database volume directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ geoip_db_dir }}",
          state = Some "directory",
          owner = Some "{{ _user.uid }}",
          group = Some "{{ _user.group }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Install files",
      template = Some {
        src = "{{ item.src }}",
        dest = "{{ item.dest }}",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      with_items = Some (Task.Poly_with_items.Records [
          { src = "README.md", dest = "{{ geoip_home }}/README.md" }
        , { src = "Makefile", dest = "{{ geoip_home }}/Makefile" }
        , { src = "Dockerfile", dest = "{{ geoip_build_dir }}/Dockerfile" }
        , { src = "docker-compose.yml", dest = "{{ geoip_home }}/docker-compose.yml" }
      ])
    }
]
