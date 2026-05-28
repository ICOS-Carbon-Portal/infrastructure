-- Auto-generated from main.yml

{
    dbin_download_base = "/opt/downloads"
  , dbin_download_dest = "{{ dbin_download_base }}/{{ _dbin_name }}"
  , dbin_bin_dir = "/usr/local/bin"
  , dbin_default_url = "{{ dbin__down }}/v{{ dbin__vers }}/{{ dbin_repo }}-{{ dbin__vers }}.{{ dbin__plat }}.tar.gz"
  , dbin_arch = "amd64"
  , _dbin_url = "{{ dbin_url | default(dbin_default_url) }}"
  , _dbin_unar = "{{ dbin_unar | default(True) }}"
  , _dbin_path = "{{ dbin_path | default(dbin_repo) }}"
  , _dbin_name = "{{ _dbin_path | basename }}"
  , _dbin_src = ''
    {% if dbin_src is defined -%}
    {{ dbin_download_dest }}/{{ dbin_src -}}
    {% elif _dbin_unar -%}
    {{ dbin_download_dest }}/{{ _unar.files[0].rstrip('/') }}/{{ _dbin_name -}}
    {%- else %}
    {{- dbin_download.dest }}
    {%- endif %}
  ''
  , dbin__down = "https://github.com/{{ dbin_user }}/{{ dbin_repo }}/releases/download"
  , dbin__vers = "{{ _release.tag.lstrip('v') }}"
  , dbin__plat = "linux-{{ dbin_arch }}"
}
