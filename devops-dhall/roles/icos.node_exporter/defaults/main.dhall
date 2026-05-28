-- Auto-generated from main.yml

{
    node_exporter_user = "node_exporter"
  , node_exporter_home = "/opt/node_exporter"
  , node_exporter_download = "{{ node_exporter_home }}/download"
  , node_exporter_textfiles = "{{ node_exporter_home }}/textfiles"
  , node_exporter_environ = "{{ node_exporter_home }}/environ"
  , node_exporter_bin = "/usr/local/sbin/node_exporter"
  , node_exporter_listen = 9100
  , node_exporter_bindto = "lo"
  , node_exporter_allow = False
  , node_exporter_arch = ''
    {{ node_exporter_arch_map[ansible_architecture] |
       default(ansible_architecture) }}
  ''
  , node_exporter_arch_map = { armv6l = "armv6", armv7l = "armv7", x86_64 = "amd64" }
  , dirsize_enable = False
  , dirsize_home = "{{ node_exporter_home }}/directory-size"
  , dirsize_sh = "{{ node_exporter_scripts }}/directory-size.sh"
  , dirsize_dirnames = "{{ dirsize_home }}/dirnames.txt"
  , dirsize_prom = "{{ node_exporter_textfiles }}/directory-size.prom"
  , dirsize_initial = [] : List Text
  , dockermon_enable = False
  , dockermon_home = "{{ node_exporter_home }}/dockermon"
  , dockermon_prom = "{{ node_exporter_textfiles }}/dockermon.prom"
  , lxdmon_enable = False
}
