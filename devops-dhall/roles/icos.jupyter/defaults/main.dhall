-- Auto-generated from ../../../../devops/roles/icos.jupyter/defaults/main.yml

{
    jupyter_home = "/docker/jupyter"
  , jupyter_port = 8000
  , jupyter_jusers_enable = False
  , jupyter_hub_config_defaults = {
      user_volumes = {=}
    , admin_users = [] : List Text
    , image = "registry.icos-cp.eu/icosbase"
  }
  , jupyter_hub_config = {=}
  , jusers_home = "/opt/jusers"
  , jusers_venv = "{{ jusers_home }}/venv"
}
