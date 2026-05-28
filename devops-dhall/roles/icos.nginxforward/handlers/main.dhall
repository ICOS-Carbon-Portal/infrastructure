-- Auto-generated from main.yml

[
    {
      name = "reload nginx config"
    , shell = ''
      nginx -t && systemctl reload nginx

    ''
  }
]
