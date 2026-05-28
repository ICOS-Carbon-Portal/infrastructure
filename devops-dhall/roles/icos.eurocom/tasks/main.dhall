-- Auto-generated from main.yml

let Item =
    { Type =
        { include_role : Text
    , vars : { certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxauth_file : Optional Text, nginxauth_users : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text }
    , when : Optional Text
  }
    , default =
        { when = None Text
  }
    }

in  [
    Item::{
      include_role = "name=icos.certbot2",
      vars = {
        certbot_name = Some "{{ eurocom_domain }}"
      , certbot_domains = Some [ "{{ eurocom_domain }}" ]
      , nginxauth_file = None Text
      , nginxauth_users = None Text
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    }
    }
  , Item::{
      include_role = "name=icos.nginxauth",
      vars = {
        certbot_name = None Text
      , certbot_domains = None (List Text)
      , nginxauth_file = Some "{{ eurocom_auth_file }}"
      , nginxauth_users = Some "{{ eurocom_users }}"
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    },
      when = Some "eurocom_users is defined"
    }
  , Item::{
      include_role = "name=icos.nginxsite",
      vars = {
        certbot_name = None Text
      , certbot_domains = None (List Text)
      , nginxauth_file = None Text
      , nginxauth_users = None Text
      , nginxsite_name = Some "eurocom"
      , nginxsite_file = Some "roles/icos.eurocom/templates/eurocom.conf"
    }
    }
]
