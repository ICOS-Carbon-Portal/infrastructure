-- Auto-generated from requirements.yml

{
    collections = let Entry =
      { Type =
          { name : Text
      , version : Optional Text
    }
      , default =
          { version = None Text
    }
      }

  in  [
      Entry::{ name = "community.general", version = Some ">=9.0.0" }
    , Entry::{ name = "ansible.posix" }
    , Entry::{ name = "community.docker" }
    , Entry::{ name = "community.mysql" }
    , Entry::{ name = "community.postgresql" }
    , Entry::{ name = "community.crypto" }
  ]
}
