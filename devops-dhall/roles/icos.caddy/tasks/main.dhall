-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional Text
    , name : Optional Text
    , include_tasks : Optional Text
    , when : Optional Text
    , `ansible.builtin.shell` : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { import_tasks = None Text
    , tags = None Text
    , name = None Text
    , include_tasks = None Text
    , when = None Text
    , `ansible.builtin.shell` = None Text
    , changed_when = None Bool
  }
    }

in  [
    Item::{ import_tasks = Some "install.yml" }
  , Item::{ import_tasks = Some "just.yml", tags = Some "caddy_just" }
  , Item::{
      name = Some "Install plain caddy",
      include_tasks = Some "plain.yml",
      when = Some "not caddy_modules"
    }
  , Item::{
      tags = Some "caddy_xcaddy",
      include_tasks = Some { file = "xcaddy.yml", apply = { tags = "caddy_modules" } },
      when = Some "caddy_modules"
    }
  , Item::{
      name = Some "Check that caddy was properly installed",
      `ansible.builtin.shell` = Some "{{ caddy_bin }} version",
      changed_when = Some False
    }
  , Item::{ name = Some "Set caddy global configuration", include_tasks = Some "global.yml" }
  , Item::{
      tags = Some "caddy_site",
      name = Some "Configure caddy site",
      include_tasks = Some { file = "site.yml", apply = { tags = "caddy_site" } },
      when = Some "caddy_name is defined"
    }
]
