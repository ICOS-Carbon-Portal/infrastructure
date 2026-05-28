-- Auto-generated from quince-tomcat.yml

let Entry =
    { Type =
        { name : Text
    , get_url : Optional ({ url : Text, dest : Text })
    , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool, owner : Text, group : Text })
    , diff : Optional Bool
    , find : Optional ({ file_type : Text, recurse : Bool, paths : Text, patterns : Text })
    , register : Optional Text
    , set_fact : Optional ({ quince_tomcat_dir : Text })
    , file : Optional ({ dest : Text, src : Text, state : Text })
    , template : Optional ({ src : Text, dest : Text })
    , notify : Optional Text
    , service : Optional ({ name : Text, state : Text, enabled : Bool })
  }
    , default =
        { get_url = None ({ url : Text, dest : Text })
    , unarchive = None ({ src : Text, dest : Text, remote_src : Bool, owner : Text, group : Text })
    , diff = None Bool
    , find = None ({ file_type : Text, recurse : Bool, paths : Text, patterns : Text })
    , register = None Text
    , set_fact = None ({ quince_tomcat_dir : Text })
    , file = None ({ dest : Text, src : Text, state : Text })
    , template = None ({ src : Text, dest : Text })
    , notify = None Text
    , service = None ({ name : Text, state : Text, enabled : Bool })
  }
    }

in  [
    Entry::{
      name = "Download tomcat binary",
      get_url = Some { url = "{{ quince_tomcat_url }}", dest = "/opt/tomcat.tgz" }
    }
  , Entry::{
      name = "Unarchive /opt/tomcat.tgz",
      unarchive = Some {
        src = "/opt/tomcat.tgz"
      , dest = "/opt"
      , remote_src = True
      , owner = "{{ quince_user }}"
      , group = "{{ quince_user }}"
    },
      diff = Some False
    }
  , Entry::{
      name = "Find the unpackad tomcat directory",
      find = Some {
        file_type = "directory"
      , recurse = False
      , paths = "/opt"
      , patterns = "apache-tomcat-*"
    },
      register = Some "_fs"
    }
  , Entry::{
      name = "Extract the version-specific directory of tomcat",
      set_fact = Some {
        quince_tomcat_dir = "{{ (_fs.files | sort(attribute='path') | last).path  }}"
    }
    }
  , Entry::{
      name = "Create /opt/tomcat symlink",
      file = Some {
        dest = "{{ quince_tomcat_home }}"
      , src = "{{ quince_tomcat_dir }}"
      , state = "link"
    }
    }
  , Entry::{
      name = "Create /usr/bin/catalina.sh symlink",
      file = Some {
        dest = "/usr/bin/catalina.sh"
      , src = "{{ quince_tomcat_home }}/bin/catalina.sh"
      , state = "link"
    }
    }
  , Entry::{
      name = "Copy quince.service",
      template = Some { src = "quince.service", dest = "/etc/systemd/system/quince.service" },
      notify = Some "reload systemd config"
    }
  , Entry::{
      name = "Enable QuinCe service",
      service = Some { name = "quince", state = "started", enabled = True }
    }
]
