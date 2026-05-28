-- Auto-generated from proxy.yml

[
    {
      name = "Create cpmeta certificate",
      include_role = "name=icos.certbot2",
      vars = {
        certbot_name = Some "{{ cpmeta_certbot_name }}"
      , certbot_domains = Some "{{ cpmeta_domains }}"
      , nginxsite_name = None Text
      , nginxsite_file = None Text
    }
    }
  , {
      name = "Add cpmeta nginx config",
      include_role = "name=icos.nginxsite",
      vars = {
        certbot_name = None Text
      , certbot_domains = None Text
      , nginxsite_name = Some "{{ cpmeta_nginxsite_name }}"
      , nginxsite_file = Some "cpmeta.conf"
    }
    }
]
