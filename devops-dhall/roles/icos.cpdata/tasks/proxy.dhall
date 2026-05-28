-- Auto-generated from proxy.yml

[
    {
      name = "Create cpdata certificate",
      include_role = "name=icos.certbot2",
      vars = {
        certbot_name = Some "{{ cpdata_certbot_name }}"
      , certbot_domains = Some "{{ cpdata_domains }}"
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    }
    }
  , {
      name = "Add cpdata nginx config",
      include_role = "name=icos.nginxsite",
      vars = {
        certbot_name = None Text
      , certbot_domains = None Text
      , nginxsite_name = Some "{{ cpdata_nginxsite_name }}"
      , nginxsite_file = Some "cpdata.conf"
    }
    }
]
