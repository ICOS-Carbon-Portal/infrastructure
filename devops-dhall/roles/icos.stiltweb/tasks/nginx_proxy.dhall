-- Auto-generated from nginx_proxy.yml

[
    {
      name = "Create stiltweb certificate",
      include_role = { name = "icos.certbot2", public = Some True },
      vars = {
        certbot_name = Some "{{ stiltweb_certbot_name }}"
      , certbot_domains = Some "{{ stiltweb_domains }}"
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    }
    }
  , {
      name = "Add stiltweb nginx config",
      include_role = { name = "icos.nginxsite", public = None Bool },
      vars = {
        certbot_name = None Text
      , certbot_domains = None Text
      , nginxsite_name = Some "{{ stiltweb_nginxsite_name }}"
      , nginxsite_file = Some "stiltweb-nginx.conf"
    }
    }
]
