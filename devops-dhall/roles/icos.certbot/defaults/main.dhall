-- Auto-generated from main.yml

{
    certbot_disabled = False
  , certbot_fake_certificate = False
  , certbot_conf_path = "/etc/nginx/conf.d/{{ certbot_conf_name }}.conf"
  , certbot_email = "carbon.admin@nateko.lu.se"
  , certbot_bin = "certbot"
  , certbot_live_crt = "/etc/letsencrypt/live/{{ certbot_domains | first }}/fullchain.pem"
  , certbot_live_key = "/etc/letsencrypt/live/{{ certbot_domains | first }}/privkey.pem"
  , certbot_fake_cn = "{{ certbot_conf_name }}"
}
