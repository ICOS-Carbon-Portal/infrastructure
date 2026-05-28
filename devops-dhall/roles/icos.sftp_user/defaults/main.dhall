-- Auto-generated from main.yml

{
    sftp_user_owner = "{{ sftp_user_login }}"
  , sftp_user_group = "{{ sftp_user_owner }}"
  , sftp_user_password = None Text
  , sftp_user_pubkey = None Text
  , sftp_user_hostdesc = "{{ inventory_hostname }}"
  , _sftp_parent_dir = "{{ sftp_user_dir | dirname }}"
  , _sftp_create_home = "{{ sftp_authorized_keys | bool }}"
}
