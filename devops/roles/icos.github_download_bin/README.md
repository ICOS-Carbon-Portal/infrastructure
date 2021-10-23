This role will install commandline tools from github and symlink them into PATH.

    - name: Install promtool, amtool and blackbox_exporter
      import_role:
        name: icos.github_download_bin
      vars:
        dbin_list:
          - user: prometheus
            repo: prometheus
            path: promtool

          - user: prometheus
            repo: alertmanager
            path: amtool

          - user: prometheus
            repo: blackbox_exporter
            path: blackbox_exporter


The previous will:

  * Create /opt/download
  * Download tarballs.
  * Unpack tarballs.
  * Symlink /opt/download/unpacked/{{ path }} to /usr/local/sbin/
