-- Auto-generated from ../../../../devops/roles/icos.sshlogin/defaults/main.yml

{
    sshlogin_dst_from = None Text
  , sshlogin_dst_command = None Text
  , sshlogin_dst_restrict = None Text
  , sshlogin_dst_ssh_dir = "{{ _dst_user.home }}/.ssh"
  , sshlogin_dst_known_hosts = "{{ sshlogin_dst_ssh_dir }}/known_hosts"
  , sshlogin_dst_key_file = "{{ sshlogin_dst_ssh_dir }}/id_rsa"
  , sshlogin_dst_key_options = "{{ _sshlogin_opt_list | select('ne', '') | join(',') }}"
  , _sshlogin_opt_list = [
      "{% if sshlogin_dst_command -%} command=\"{{ sshlogin_dst_command}}\" {%- endif -%}"
    , "{% if sshlogin_dst_from == 'srcip' -%} from=\"{{ sshlogin_src_ip }}\" {%- elif sshlogin_dst_from -%} from=\"{{ sshlogin_dst_from }}\" {%- endif -%}"
    , "{% if sshlogin_dst_restrict -%} restrict {%- endif -%}"
  ]
  , sshlogin_src_dst = "{{ sshlogin_dst }}"
  , sshlogin_src_ssh_dir = "{{ _src_user.home }}/.ssh"
  , sshlogin_src_ssh_config = "{{ sshlogin_src_ssh_dir }}/config"
  , sshlogin_src_known_hosts = "{{ sshlogin_src_ssh_dir }}/known_hosts"
  , sshlogin_src_key_file = "{{ sshlogin_src_ssh_dir }}/id_rsa"
  , sshlogin_src_dst_name = "{{ sshlogin_dst }}"
  , sshlogin_src_dst_host = "{{ hostvars[sshlogin_dst].ansible_host | default(sshlogin_dst) }}"
  , sshlogin_src_dst_port = "{{ hostvars[sshlogin_dst].ansible_port | default(22) }}"
}
