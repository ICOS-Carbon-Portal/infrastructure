-- Auto-generated from ../../../../devops/roles/icos.jarservice/defaults/main.yml

{
    jarservice_keep_n_old = 10
  , jarservice_jar = "{{ _user.home}}/{{ servicename }}.jar"
  , extra_groups = ""
  , certbot_disabled = False
}
