-- Auto-generated from cli.yml

let Entry =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text })
    , template : Optional ({ src : Text, mode : Text, dest : Text })
    , cron : Optional ({ user : Text, job : Text, hour : Text, minute : Text, name : Text })
  }
    , default =
        { file = None ({ path : Text, state : Text, owner : Text, group : Text })
    , template = None ({ src : Text, mode : Text, dest : Text })
    , cron = None ({ user : Text, job : Text, hour : Text, minute : Text, name : Text })
  }
    }

in  [
    Entry::{
      name = "Create {{ bbserver_home }}/bin directory",
      file = Some {
        path = "{{ bbserver_home }}/bin"
      , state = "directory"
      , owner = "{{ bbserver_user }}"
      , group = "{{ bbserver_user }}"
    }
    }
  , Entry::{
      name = "Copy bbserver.py",
      template = Some { src = "bbserver.py", mode = "+x", dest = "{{ bbserver_home }}/bin/bbserver" }
    }
  , Entry::{
      name = "Prime borg cache by running 'bbserver list' each night",
      cron = Some {
        user = "bbserver"
      , job = "{{ bbserver_home }}/bin/bbserver list > /dev/null 2>&1"
      , hour = "{{ 4 | random(seed='bbserver') }}"
      , minute = "{{ 60 | random(seed='bbserver') }}"
      , name = "bbserver_prime_borg_cache"
    }
    }
]
