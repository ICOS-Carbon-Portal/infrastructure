-- Auto-generated from ../../../../devops/roles/icos.stiltweb/defaults/main.yml

{
    stiltweb_username = "stiltweb"
  , stiltweb_home = "/home/{{ stiltweb_username }}"
  , stiltweb_bindir = "{{ stiltweb_home }}/bin"
  , stiltweb_akka_port = 2550
  , stiltweb_akka_hostname = "{{ inventory_hostname }}"
  , stiltweb_java = "/usr/bin/java"
  , stiltweb_jre_package = "openjdk-11-jre-headless"
  , stiltweb_certbot_name = "stiltweb"
  , stiltweb_nginxsite_name = "stiltweb"
}
