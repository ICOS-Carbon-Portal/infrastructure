-- Auto-generated from ../../../../devops/roles/icos.jarservice/tasks/jarfile.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create directory for jar files",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ _user.home }}/jarfiles",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      register = Some "jardir"
    }
  , Task::{
      name = Some "Get checksum of local jar file.",
      become = Some (Task.Poly_become.Bool False),
      local_action = Some (Task.Poly_local_action.Str "stat path=\"{{jarfile}}\" checksum_algorithm=sha256"),
      register = Some "_stat"
    }
  , Task::{
      name = Some "To aid debugging, explicitly check that the local jar file exist.",
      fail = Some { msg = "{{ jarfile }} doesn't exist!" },
      when = Some [ "not _stat.stat.exists" ]
    }
  , Task::{
      name = Some "Compute the destination filename, we'll be using it more than once.",
      set_fact = Some (Task.Poly_set_fact.Record {
          certbot_nginx_conf = None Text,
          destjarfile = Some "{{jardir.path}}/{{jarfile|basename}}-{{_stat.stat.checksum}}",
          name = None Text,
          nebula_resolve_type = None Text,
          cacheable = None Bool,
          nebula_ssh_public = None Text,
          quince_tomcat_dir = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text,
          _wg_is_installed = None Natural
      })
    }
  , Task::{
      name = Some "Copy {{ servicename }} jar file",
      copy = Some {
        dest = "{{ destjarfile }}",
        mode = None Text,
        content = None Text,
        src = Some "{{ jarfile }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Create the {{ servicename}} jar symlink used by systemd",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "{{ jarservice_jar }}",
          recurse = None Bool,
          src = Some "{{ destjarfile }}"
      }),
      notify = Some [ "restart {{ servicename }}" ]
    }
  , Task::{
      name = Some "Keep the jarfiles directory from filling up",
      shell = Some "ls -1t {{ jardir.path }}/*.jar-* 2>/dev/null | sed '1,{{jarservice_keep_n_old}}d'",
      register = Some "oldjarfiles",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Remove old jarfiles",
      file = Some (Task.Poly_file.Str "path={{ item }} state=absent"),
      with_items = Some (Task.Poly_with_items.Texts [ "{{ oldjarfiles.stdout_lines }}" ])
    }
]
