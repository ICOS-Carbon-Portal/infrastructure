-- Auto-generated from main.yml

{
    restheart_user = "restheart"
  , restheart_home = "{{ docker_compose_home | default('/docker') }}/restheart"
  , restheart_bind_host = "127.0.0.1"
  , restheart_bind_port = 8088
  , restheart_host = "{{ restheart_bind_host }}"
  , restheart_port = "{{ restheart_bind_port }}"
  , restheart_nginxsite_name = "restheart"
}
