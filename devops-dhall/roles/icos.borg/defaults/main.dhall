-- Auto-generated from ../../../../devops/roles/icos.borg/defaults/main.yml

{
    borg_upgrade = "{{ upgrade_everything | default(False) | bool }}"
  , borg_version = "{{ hostvars.localhost.borg_version }}"
  , borg_url_map = {
      x86_64 = "https://github.com/borgbackup/borg/releases/download/{{ borg_version }}/borg-linux-glibc{{ borg_libc_version }}"
  }
  , borg_bin = "/usr/local/bin/borg"
  , borg_libc_map = { Ubuntu = { `22.04` = "231", `24.04` = "236" } }
  , borg_libc_version = "{{ borg_libc_map[ansible_distribution][ansible_distribution_version] }}"
}
