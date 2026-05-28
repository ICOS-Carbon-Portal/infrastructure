-- Auto-generated from proxy.yml

[
    {
      include_role = "name=icos.certbot2",
      vars = {
        certbot_name = Some "{{ restheart_certbot_name }}"
      , certbot_domains = Some "{{ restheart_domains }}"
      , nginxauth_conf = None Text
      , nginxsite_name = None Text
      , nginxsite_file = None Text
      , nginxsite_users = None (List Text)
    }
    }
  , {
      include_role = "name=icos.nginxsite",
      vars = {
        certbot_name = None Text
      , certbot_domains = None Text
      , nginxauth_conf = Some ''
        auth_basic "Login required";
        auth_basic_user_file "/etc/nginx/auth/{{ restheart_nginxsite_name }}";

      ''
      , nginxsite_name = Some "{{ restheart_nginxsite_name }}"
      , nginxsite_file = Some "restheart-nginx.conf"
      , nginxsite_users = Some [ "{{ restheart_basic_auth }}" ]
    }
    }
]
