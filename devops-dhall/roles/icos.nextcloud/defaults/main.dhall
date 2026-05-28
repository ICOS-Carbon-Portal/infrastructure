-- Auto-generated from main.yml

{
    nextcloud_nextcloud_version = "29.0.11"
  , nextcloud_postgres_version = 13.18
  , nextcloud_port = 9000
  , nextcloud_user = "nextcloud"
  , nextcloud_home = "/docker/nextcloud"
  , nextcloud_domain = "fileshare.icos-cp.eu"
  , nextcloud_certbot_enable = True
  , certbot_domains = [ "{{ nextcloud_domain }}" ]
  , certbot_name = "nextcloud"
  , nextcloud_volume_nextcloud = "{{ nextcloud_home }}/volumes/nextcloud"
  , nextcloud_volume_postgres = "{{ nextcloud_home }}/volumes/postgres"
  , nextcloud_db_name = "nextcloud"
  , nextcloud_db_user = "nextcloud"
  , nextcloud_db_host = "db"
  , nextcloud_exporter_conf_host = "{{ nextcloud_home }}/nextcloud-exporter.conf"
  , nextcloud_exporter_user = "nextcloud-exporter"
  , nextcloud_exporter_port = 9205
  , nextcloud_volumes = [] : List Text
}
