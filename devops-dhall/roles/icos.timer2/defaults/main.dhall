-- Auto-generated from main.yml

{
    timer_home = "/etc/systemd/system"
  , timer_dest = "{{ timer_home }}/{{ timer_name }}"
  , _timer_sysd_timer = "{{ timer_home }}/{{ timer_name }}.timer"
  , _timer_sysd_service = "{{ timer_home }}/{{ timer_name }}.service"
  , timer_state = "started"
}
