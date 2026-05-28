-- Auto-generated from proxy.yml

[
    {
      name = "Create doi certificate",
      include_role = "name=icos.certbot2",
      vars = {
        certbot_name = Some "{{ doi_certbot_name }}"
      , certbot_domains = Some "{{ doi_domains }}"
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    }
    }
  , {
      name = "Add doi nginx config",
      include_role = "name=icos.nginxsite",
      vars = {
        certbot_name = None Text
      , certbot_domains = None Text
      , nginxsite_name = Some "{{ doi_nginxsite_name }}"
      , nginxsite_file = Some "doi.conf"
    }
    }
]
