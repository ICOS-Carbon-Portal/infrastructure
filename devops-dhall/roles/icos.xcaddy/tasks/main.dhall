-- Auto-generated from main.yml

let Item =
    { Type =
        { import_role : Optional Text
    , import_tasks : Optional Text
    , when : Optional Text
  }
    , default =
        { import_role = None Text
    , import_tasks = None Text
    , when = None Text
  }
    }

in  [
    Item::{ import_role = Some "name=icos.golang" }
  , Item::{
      import_tasks = Some "xcaddy-debian.yml",
      when = Some "ansible_distribution_file_variety == 'Debian'"
    }
  , Item::{
      import_tasks = Some "xcaddy-other.yml",
      when = Some "ansible_distribution_file_variety != 'Debian'"
    }
]
