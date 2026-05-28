-- Auto-generated from proxy.yml

let Item =
    { Type =
        { when : Optional Text
    , name : Optional Text
    , check_mode : Optional Bool
    , shellfact : Optional ({ exec : Text, fact : Text })
    , fail : Optional ({ msg : Text })
    , include_role : Optional ({ name : Text, tasks_from : Optional Text })
    , meta : Optional Text
    , block : Optional (List ({ name : Text, uri : { url : Text, user : Optional Text, password : Optional Text }, retries : Natural, register : Text, failed_when : Optional Text }))
  }
    , default =
        { when = None Text
    , name = None Text
    , check_mode = None Bool
    , shellfact = None ({ exec : Text, fact : Text })
    , fail = None ({ msg : Text })
    , include_role = None ({ name : Text, tasks_from : Optional Text })
    , meta = None Text
    , block = None (List ({ name : Text, uri : { url : Text, user : Optional Text, password : Optional Text }, retries : Natural, register : Text, failed_when : Optional Text }))
  }
    }

in  [
    Item::{
      when = Some "vmagent_proxy == \"probe\"",
      name = Some "Probe for vmagent_proxy fact",
      check_mode = Some False,
      shellfact = Some {
        exec = "ss -Htlp 'sport 443' | sed -re 's/.*(nginx|caddy).*/\\1/' | uniq"
      , fact = "vmagent_proxy"
    }
    }
  , Item::{
      when = Some "vmagent_proxy not in ('nginx', 'caddy')",
      name = Some "Fail if we can't figure out which proxy server is used",
      check_mode = Some False,
      fail = Some {
        msg = ''
        Unknown proxy server "{{ vmagent_proxy }}".

      ''
    }
    }
  , Item::{
      when = Some "vmagent_proxy == 'nginx'",
      name = Some "Setup nginx proxy for vmagent",
      include_role = Some { name = "icos.nginxsite", tasks_from = None Text }
    }
  , Item::{
      when = Some "vmagent_proxy == 'caddy'",
      name = Some "Setup caddy proxy for vmagent",
      include_role = Some { name = "icos.caddy", tasks_from = Some "site.yml" }
    }
  , Item::{ name = Some "Flush handlers", meta = Some "flush_handlers" }
  , Item::{
      when = Some "vmagent_auth",
      block = Some [
        {
          name = "Test that the vmagent UI is password protected",
          uri = {
            url = "https://{{ inventory_hostname }}/vmagent/"
          , user = None Text
          , password = None Text
        },
          retries = 10,
          register = "r",
          failed_when = Some "r.status != 401"
        }
      , {
          name = "Test that the vmagent UI works with password",
          uri = {
            url = "https://{{ inventory_hostname }}/vmagent/"
          , user = Some "{{ vmagent_auth.username }}"
          , password = Some "{{ vmagent_auth.password }}"
        },
          retries = 10,
          register = "r",
          failed_when = None Text
        }
    ]
    }
]
