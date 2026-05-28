-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , apt_key : Optional ({ id : Text, url : Text, state : Text })
    , apt_repository : Optional ({ repo : Text, filename : Text })
    , apt : Optional ({ name : Text })
    , when : Optional Text
    , pip : Optional ({ name : Text, state : Text })
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text })
    , lineinfile : Optional ({ owner : Text, group : Text, create : Bool, path : Text, regex : Text, line : Text, state : Text })
  }
    , default =
        { apt_key = None ({ id : Text, url : Text, state : Text })
    , apt_repository = None ({ repo : Text, filename : Text })
    , apt = None ({ name : Text })
    , when = None Text
    , pip = None ({ name : Text, state : Text })
    , file = None ({ path : Text, state : Text, owner : Text, group : Text })
    , lineinfile = None ({ owner : Text, group : Text, create : Bool, path : Text, regex : Text, line : Text, state : Text })
  }
    }

in  [
    Task::{
      name = "Adding the apt key for postgresql",
      apt_key = Some {
        id = "ACCC4CF8"
      , url = "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
      , state = "present"
    }
    }
  , Task::{
      name = "Adding the postgresql repo",
      apt_repository = Some {
        repo = "deb http://apt.postgresql.org/pub/repos/apt/ {{ansible_distribution_release}}-pgdg main"
      , filename = "pgdg"
    }
    }
  , Task::{
      name = "Install postgresql",
      apt = Some { name = "{{ 'postgresql-%s' % postgresql_version }}" }
    }
  , Task::{
      name = "Install postgis",
      apt = Some { name = "{{ 'postgresql-%s-postgis-3' % postgresql_version }}" },
      when = Some "postgresql_postgis_enable"
    }
  , Task::{
      name = "Install python3 psycopg2-binary library",
      pip = Some { name = "psycopg2-binary", state = "present" }
    }
  , Task::{
      name = "Create {{ postgresql_bin }} directory",
      file = Some {
        path = "{{ postgresql_bin }}"
      , state = "directory"
      , owner = "postgres"
      , group = "postgres"
    }
    }
  , Task::{
      name = "Modify ~/.profile",
      lineinfile = Some {
        owner = "postgres"
      , group = "postgres"
      , create = True
      , path = "{{ postgresql_home }}/.profile"
      , regex = "^PATH="
      , line = "PATH=$HOME/bin:$PATH"
      , state = "present"
    }
    }
]
