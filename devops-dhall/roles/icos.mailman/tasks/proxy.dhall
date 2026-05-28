-- Auto-generated from proxy.yml

[
    {
      name = "Create mailman certificate",
      include_role = { name = "icos.certbot2", public = True },
      vars = {
        certbot_name = Some "{{ mailman_certbot_name }}"
      , certbot_domains = Some "{{ mailman_domains }}"
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    }
    }
  , {
      name = "Create mailmain nginx config",
      include_role = "name=icos.nginxsite",
      vars = {
        certbot_name = None Text
      , certbot_domains = None Text
      , nginxsite_name = Some "{{ mailman_nginxsite_name }}"
      , nginxsite_file = Some "{{ mailman_nginxsite_file }}"
    }
    }
]
