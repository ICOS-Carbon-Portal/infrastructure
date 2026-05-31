import { type Playbook, role, tmpl } from "../../lib/ansible.ts";

export default [
  // ### FSICOS2 ###
  {
    hosts: "fsicos2",
    vars_files: "vars/downtime.yml",
    tasks: [
      // NGINX
      {
        name: "Create local certificate directories",
        tags: "nginx",
        delegate_to: "localhost",
        become: false,
        file: { path: tmpl("{{ item }}"), state: "directory" },
        loop: [tmpl("{{ local_cert_dir }}"), tmpl("{{ local_conf_dir }}")],
      },
      {
        name: "Pull certificates",
        tags: "nginx",
        "ansible.posix.synchronize": {
          mode: "pull",
          copy_links: true,
          src: `/etc/letsencrypt/live/{{ "{" + ",".join(certificates) + "}" }}
`,
          dest: tmpl("{{ local_cert_dir }}/"),
        },
      },
      {
        name: "Pull configuration",
        tags: "nginx",
        "ansible.posix.synchronize": {
          mode: "pull",
          copy_links: true,
          rsync_opts: [
            // Create local directories below dest directory
            "--mkpath",
          ],
          src: `/etc/nginx/{{ "{" + ",".join(configurations) + "}" }}
`,
          dest: tmpl("{{ local_conf_dir }}"),
        },
      },
      // CPMETA
      {
        name: "Pull cpmeta.jar",
        tags: "cpmeta",
        "ansible.posix.synchronize": {
          mode: "pull",
          copy_links: true,
          src: "/home/cpmeta/cpmeta.jar",
          dest: tmpl("{{ local_tmp }}/"),
        },
      },
      {
        name: "Synchronize metaAppStorage",
        "ansible.posix.synchronize": {
          mode: "pull",
          owner: false,
          group: false,
          src: "/disk/data/metaAppStorage",
          dest: tmpl("{{ local_tmp }}/"),
        },
      },
      // RDFLOG
      // It's in the order of 400M compressed.
      {
        name: "Dump rdflog database",
        tags: "rdflog",
        "ansible.builtin.shell":
          "docker-compose exec -T db pg_dump -Cc --if-exists -d rdflog | gzip -c > /tmp/rdflog_dump.gz",
        args: {
          chdir: "/docker/rdflog",
          creates: "/tmp/rdflog_dump.gz",
          executable: "/bin/bash", // in case we use bash-ism
        },
      },
      {
        name: "Pull rdflog_dump.gz",
        tags: "rdflog",
        "ansible.posix.synchronize": {
          mode: "pull",
          owner: false,
          group: false,
          src: "/tmp/rdflog_dump.gz",
          dest: tmpl("{{ local_tmp }}/"),
        },
      },
    ],
  },

  // ### ICOS1 ###
  {
    hosts: "icos1",
    vars_files: "vars/downtime.yml",
    vars: {
      // Meta should listen to 127.0.0.1, nginx will then reverse-proxy there.
      coreapp_bind_addr: "127.0.0.1",
      cpmeta_backup_enable: false,
      cpmeta_readonly_mode: true,
    },
    handlers: [
      {
        name: "reload nginx",
        systemd: { name: "nginx", state: "reloaded" },
      },
    ],
    pre_tasks: [
      // NGINX
      {
        name: "Push certificates",
        tags: "nginx",
        "ansible.posix.synchronize": {
          mode: "push",
          src: tmpl("{{ local_cert_dir }}/"),
          dest: "/etc/letsencrypt/live/",
          owner: false,
          group: false,
          perms: false,
        },
        notify: "reload nginx",
      },
      // Since we copy files directly to live/ and don't use the standard system
      // of symlinks, we'll have to protect the certificates.
      {
        name: "Change access rights on /etc/letsencrypt/live",
        tags: "nginx",
        file: { path: "/etc/letsencrypt/live", mode: 0o700 },
      },
      {
        name: "Push configuration",
        tags: "nginx",
        "ansible.posix.synchronize": {
          mode: "push",
          src: tmpl("{{ local_conf_dir }}/"),
          dest: "/etc/nginx/conf.d",
          owner: false,
          group: false,
        },
        notify: "reload nginx",
      },
      // RDFLOG
      {
        name: "Push rdflog dump",
        tags: "rdflog",
        "ansible.posix.synchronize": {
          owner: false,
          group: false,
          src: tmpl("{{ local_tmp }}/rdflog_dump.gz"),
          dest: "/tmp/",
        },
      },
      // CPMETA
      // metaAppStorage doesn't compress very well, so just rsync the directory
      {
        name: "Push metaAppStorage",
        "ansible.posix.synchronize": {
          src: tmpl("{{ local_tmp }}/metaAppStorage"),
          dest: "/home/cpmeta/",
          // Create local directories below dest directory
          rsync_opts: ["--mkpath"],
          // ("yes") preserve owner and group
          owner: false,
          group: false,
          // ("no") delete extraneous files from dest dirs
          delete: false,
        },
      },
    ],
    roles: [
      // RDFLOG
      role("icos.rdflog", {
        rdflog_postgres_version: 10,
        rdflog_rep_pass: tmpl("{{ vault_rdflog_rep_pass }}"),
        rdflog_restore_file: tmpl("{{ local_tmp }}/rdflog_dump.gz"),
      }).tags("rdflog"),

      // CPMETA
      role("icos.cpmeta", {
        cpmeta_filestorage_target: tmpl("{{ cpmeta_home }}/metaAppStorage"),
        cpmeta_jar_file: tmpl("{{ local_tmp }}/cpmeta.jar"),
        cpmeta_config_files: [
          "application_production.conf",
          "application_production_sensitive.conf",
          "application_failover_amendment.conf",
        ],
      }).tags("cpmeta"),
    ],
  },
] satisfies Playbook;
