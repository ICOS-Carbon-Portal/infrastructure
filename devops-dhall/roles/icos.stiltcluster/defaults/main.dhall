-- Auto-generated from main.yml

{
    stiltcluster_username = "stiltcluster"
  , stiltcluster_servicename = "stiltcluster"
  , stiltcluster_home = "/home/stiltcluster"
  , stiltcluster_bindir = "{{ stiltcluster_home }}/bin"
  , stiltcluster_fetch_host = None Text
  , stiltcluster_fetch_path = ''
    {{ hostvars[stiltcluster_fetch_host].stiltcluster_home
      | default(stiltcluster_home) }}/stiltcluster.jar"
  ''
  , stiltcluster_hostname = "{{ inventory_hostname }}"
  , stiltcluster_stiltweb_hostname = "{{ inventory_hostname }}"
  , stiltcluster_stiltweb_port = 2550
  , stiltcluster_port = 2561
  , stiltcluster_maxcores = 0
  , stiltcluster_docker = True
}
