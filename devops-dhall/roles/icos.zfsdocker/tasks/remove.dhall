-- Auto-generated from remove.yml

[
    {
      name = "Remove docker storage volume for {{ zfsdocker_name }}"
    , zfs = { name = "pool/docker/{{ zfsdocker_name }}", state = "absent" }
  }
]
