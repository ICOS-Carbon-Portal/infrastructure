-- Auto-generated from auth.yml

[
    {
      name = "Add restic users"
    , htpasswd = {
        path = "{{ restic_server_htpasswd }}"
      , crypt_scheme = "bcrypt"
      , name = "{{ item.name }}"
      , password = "{{ item.password }}"
      , state = "{{ item.state | default(omit) }}"
    }
    , loop = "{{ restic_server_users }}"
  }
]
