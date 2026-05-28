-- Auto-generated from jarfile.yml

let Task =
    { Type =
        { name : Text
    , file : Optional Text
    , register : Optional Text
    , become : Optional Bool
    , local_action : Optional Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , set_fact : Optional ({ destjarfile : Text })
    , copy : Optional ({ src : Text, dest : Text })
    , notify : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
    , with_items : Optional (List Text)
  }
    , default =
        { file = None Text
    , register = None Text
    , become = None Bool
    , local_action = None Text
    , fail = None ({ msg : Text })
    , when = None Text
    , set_fact = None ({ destjarfile : Text })
    , copy = None ({ src : Text, dest : Text })
    , notify = None Text
    , shell = None Text
    , changed_when = None Bool
    , with_items = None (List Text)
  }
    }

in  [
    Task::{
      name = "Create directory for jar files",
      file = Some {
        path = Some "{{ _user.home }}/jarfiles"
      , state = "directory"
      , src = None Text
      , dest = None Text
    },
      register = Some "jardir"
    }
  , Task::{
      name = "Get checksum of local jar file.",
      register = Some "_stat",
      become = Some False,
      local_action = Some "stat path=\"{{jarfile}}\" checksum_algorithm=sha256"
    }
  , Task::{
      name = "To aid debugging, explicitly check that the local jar file exist.",
      fail = Some { msg = "{{ jarfile }} doesn't exist!" },
      when = Some "not _stat.stat.exists"
    }
  , Task::{
      name = "Compute the destination filename, we'll be using it more than once.",
      set_fact = Some {
        destjarfile = "{{jardir.path}}/{{jarfile|basename}}-{{_stat.stat.checksum}}"
    }
    }
  , Task::{
      name = "Copy {{ servicename }} jar file",
      copy = Some { src = "{{ jarfile }}", dest = "{{ destjarfile }}" }
    }
  , Task::{
      name = "Create the {{ servicename}} jar symlink used by systemd",
      file = Some {
        path = None Text
      , state = "link"
      , src = Some "{{ destjarfile }}"
      , dest = Some "{{ jarservice_jar }}"
    },
      notify = Some "restart {{ servicename }}"
    }
  , Task::{
      name = "Keep the jarfiles directory from filling up",
      register = Some "oldjarfiles",
      shell = Some "ls -1t {{ jardir.path }}/*.jar-* 2>/dev/null | sed '1,{{jarservice_keep_n_old}}d'",
      changed_when = Some False
    }
  , Task::{
      name = "Remove old jarfiles",
      file = Some "path={{ item }} state=absent",
      with_items = Some [ "{{ oldjarfiles.stdout_lines }}" ]
    }
]
