-- Auto-generated from utils.yml

[
    {
      name = "Copy utilities"
    , copy = { src = "{{ item }}", dest = "/usr/local/sbin/{{ item }}", mode = 493 }
    , loop = [ "lxdfs" ]
  }
]
