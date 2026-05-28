-- Auto-generated from smart.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , `community.general.sudoers` : Optional ({ name : Text, state : Text, user : Text, commands : Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , `community.general.sudoers` = None ({ name : Text, state : Text, user : Text, commands : Text })
  }
    }

in  [
    Task::{ name = "Install smartmontools", apt = Some { name = [ "smartmontools" ] } }
  , Task::{
      name = "Allow the telegraf user to sudo /usr/sbin/smartctl",
      `community.general.sudoers` = Some {
        name = "allow-telegraf-smart"
      , state = "present"
      , user = "telegraf"
      , commands = "/usr/sbin/smartctl"
    }
    }
]
