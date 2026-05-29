-- Auto-generated from ../../../../devops/roles/icos.victoriametrics/defaults/main.yml

{
    vm_home = "/opt/victoriametrics"
  , vm_scrape_conf = ""
  , vm_vm_port = 8428
  , vm_upgrade = "{{ upgrade_everything | default(False) | bool }}"
  , vm_graf_port = 3000
  , vm_graf_url = "http://grafana.local"
  , vm_graf_plugins = "{{ vm_home }}/grafana/data/plugins"
  , vm_graf_image = "grafana/grafana"
  , vm_promlens_port = 3001
}
