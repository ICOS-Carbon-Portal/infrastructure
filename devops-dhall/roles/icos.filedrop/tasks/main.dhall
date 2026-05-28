-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, shell : Text })
    , register : Optional Text
    , apt : Optional ({ name : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ jarservice_name : Text, jarservice_home : Text, jarservice_local : Text, jarservice_unit : Text })
    , when : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , notify : Optional Text
  }
    , default =
        { user = None ({ name : Text, home : Text, shell : Text })
    , register = None Text
    , apt = None ({ name : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ jarservice_name : Text, jarservice_home : Text, jarservice_local : Text, jarservice_unit : Text })
    , when = None Text
    , copy = None ({ dest : Text, content : Text })
    , notify = None Text
  }
    }

in  [
    Task::{
      name = "Create filedrop user",
      user = Some { name = "filedrop", home = "/home/filedrop", shell = "/usr/sbin/nologin" },
      register = Some "_user"
    }
  , Task::{ name = "Install Java", apt = Some { name = "default-jdk" } }
  , Task::{
      name = "Deploy filedrop jarfile as a service",
      include_role = Some { name = "icos.jarservice2" },
      vars = Some {
        jarservice_name = "filedrop"
      , jarservice_home = "{{ _user.home }}"
      , jarservice_local = "{{ filedrop_jar_file }}"
      , jarservice_unit = "{{ lookup('template', 'filedrop.service') }}"
    },
      when = Some "filedrop_jar_file is defined"
    }
  , Task::{
      name = "Create filedrop config file",
      copy = Some {
        dest = "{{ _user.home }}/application.conf"
      , content = ''
        cpfiledrop{
                folder = "{{ filedrop_data_home }}"
        }

      ''
    },
      notify = Some "restart filedrop"
    }
]
