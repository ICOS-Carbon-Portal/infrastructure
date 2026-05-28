-- Auto-generated from stilt.yml

{
    stiltcluster_hosts = {
      vars = {
        stiltcluster_hostname = "{{ inventory_hostname }}.nebula"
      , stiltcluster_stiltweb_hostname = "fsicos2.nebula"
      , stiltcluster_fetch_host = "fsicos2"
      , stiltcluster_fetch_path = "/home/stiltcluster/stiltcluster.jar"
    }
    , hosts = {
        `fsicos4-stiltcluster` = { stilt_input_dir = "/data/stilt/Input", stiltcluster_maxcores = 50 }
      , icos1 = {
          stilt_input_dir = "/data/stilt/Input"
        , stilt_input_mount = True
        , stiltcluster_maxcores = 20
      }
    }
  }
}
