-- Auto-generated from ../../../../devops/roles/icos.quince/tasks/quince-tomcat.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Download tomcat binary",
      get_url = Some {
        url = "{{ quince_tomcat_url }}",
        dest = "/opt/tomcat.tgz",
        force = None Text,
        mode = None Text
    }
    }
  , Task::{
      name = Some "Unarchive /opt/tomcat.tgz",
      unarchive = Some {
        src = "/opt/tomcat.tgz",
        dest = "/opt",
        remote_src = True,
        owner = Some "{{ quince_user }}",
        group = Some "{{ quince_user }}",
        include = None ((List Text)),
        list_files = None Bool,
        extra_opts = None ((List Text)),
        mode = None Text,
        creates = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Find the unpackad tomcat directory",
      find = Some {
        paths = "/opt",
        patterns = "apache-tomcat-*",
        excludes = None Text,
        file_type = Some "directory",
        recurse = Some False
    },
      register = Some "_fs"
    }
  , Task::{
      name = Some "Extract the version-specific directory of tomcat",
      set_fact = Some (Task.Poly_set_fact.Record {
          certbot_nginx_conf = None Text,
          destjarfile = None Text,
          name = None Text,
          nebula_resolve_type = None Text,
          cacheable = None Bool,
          nebula_ssh_public = None Text,
          quince_tomcat_dir = Some "{{ (_fs.files | sort(attribute='path') | last).path  }}",
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text,
          _wg_is_installed = None Natural
      })
    }
  , Task::{
      name = Some "Create /opt/tomcat symlink",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "{{ quince_tomcat_home }}",
          recurse = None Bool,
          src = Some "{{ quince_tomcat_dir }}"
      })
    }
  , Task::{
      name = Some "Create /usr/bin/catalina.sh symlink",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "/usr/bin/catalina.sh",
          recurse = None Bool,
          src = Some "{{ quince_tomcat_home }}/bin/catalina.sh"
      })
    }
  , Task::{
      name = Some "Copy quince.service",
      template = Some {
        src = "quince.service",
        dest = "/etc/systemd/system/quince.service",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "reload systemd config" ]
    }
  , Task::{
      name = Some "Enable QuinCe service",
      service = Some (Task.Poly_service.Record { name = "quince", state = "started", enabled = Some True })
    }
]
