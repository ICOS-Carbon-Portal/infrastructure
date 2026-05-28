-- Auto-generated from proxy.yml

[
    {
      name = "Create cpauth certificate",
      include_role = "name=icos.certbot2",
      vars = {
        certbot_name = Some "{{ cpauth_certbot_name }}"
      , certbot_domains = Some "{{ cpauth_domains }}"
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    }
    }
  , {
      name = "Add cpauth nginx config",
      include_role = "name=icos.nginxsite",
      vars = {
        certbot_name = None Text
      , certbot_domains = None Text
      , nginxsite_name = Some "{{ cpauth_nginxsite_name }}"
      , nginxsite_file = Some "cpauth.conf"
    }
    }
]
