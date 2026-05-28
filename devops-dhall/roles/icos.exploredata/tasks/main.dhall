-- Auto-generated from main.yml

[
    {
      include_tasks = "setup.yml"
    , loop = [ "test", "prod" ]
    , loop_control = { loop_var = "exploredata_type" }
  }
]
