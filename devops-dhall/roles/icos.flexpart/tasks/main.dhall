-- Auto-generated from main.yml

[
    {
      import_tasks = "flexpart_run.yml"
    , tags = [ "flexpart_only", "flexpart_run" ]
    , when = "flexpart_install_run is defined"
  }
  , {
      import_tasks = "flexpart_ssh.yml"
    , tags = [ "flexpart_only", "flexpart_ssh" ]
    , when = "flexpart_ssh_users is defined"
  }
]
