-- Auto-generated from ../../../../devops/roles/icos.registry/defaults/main.yml

{
    registry_home = "/docker/registry"
  , registry_htpasswd_file = "{{ registry_home }}/volumes/auth/htpasswd"
  , registry_users = [] : List Text
}
