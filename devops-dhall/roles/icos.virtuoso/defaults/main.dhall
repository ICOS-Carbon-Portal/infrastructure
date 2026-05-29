-- Auto-generated from ../../../../devops/roles/icos.virtuoso/defaults/main.yml

{
    virtuoso_home = "{{ docker_compose_home | default('/docker') }}/virtuoso"
  , virtuoso_bind_host = "127.0.0.1"
  , virtuoso_http_port = 8890
  , virtuoso_host = "{{ virtuoso_bind_host }}"
  , virtuoso_port = "{{ virtuoso_http_port }}"
  , virtuoso_dba_pass = "{{ vault_virtuoso_dba_pass }}"
}
