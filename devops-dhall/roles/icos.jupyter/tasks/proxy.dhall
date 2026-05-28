-- Auto-generated from proxy.yml

let Item =
    { Type =
        { name : Optional Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , loop : Optional (List Text)
    , include_role : Optional Text
    , vars : Optional ({ certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_file : Optional Text, jupyter_cert_name : Optional Text })
  }
    , default =
        { name = None Text
    , fail = None ({ msg : Text })
    , when = None Text
    , loop = None (List Text)
    , include_role = None Text
    , vars = None ({ certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_file : Optional Text, jupyter_cert_name : Optional Text })
  }
    }

in  [
    Item::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [ "jupyter_domain" ]
    }
  , Item::{
      include_role = Some "name=icos.certbot2",
      vars = Some {
        certbot_name = Some "{{ jupyter_domain }}"
      , certbot_domains = Some [ "{{ jupyter_domain }}" ]
      , nginxsite_file = None Text
      , jupyter_cert_name = None Text
    }
    }
  , Item::{
      include_role = Some "name=icos.nginxsite",
      vars = Some {
        certbot_name = None Text
      , certbot_domains = None (List Text)
      , nginxsite_file = Some "jupyter-nginx.conf"
      , jupyter_cert_name = Some "{{ jupyter_domain }}"
    }
    }
]
