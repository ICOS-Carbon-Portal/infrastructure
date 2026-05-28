-- Auto-generated from backup.yml

[
    {
      include_role = { name = "icos.bbclient2", public = True }
    , vars = {
        bbclient_name = "drupal"
      , bbclient_home = "{{ drupal_home }}/.bbclient"
      , bbclient_timer_conf = ''
        OnCalendar=daily
        RandomizedDelaySec=1h

      ''
      , bbclient_timer_content = "{{ lookup('template', 'borgbackup.sh') }}"
    }
  }
]
