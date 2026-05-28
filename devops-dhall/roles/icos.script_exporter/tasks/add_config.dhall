-- Auto-generated from add_config.yml

[
    {
      name = "Add config to script-exporters config.yaml"
    , blockinfile = {
        path = "{{ sexp_config }}"
      , create = False
      , marker = "# {mark} {{ sexp_marker }}"
      , state = "{{ sexp_state | default('present') }}"
      , insertafter = "EOF"
      , block = "{{ sexp_block }}"
    }
    , notify = "reload script-exporter"
  }
]
