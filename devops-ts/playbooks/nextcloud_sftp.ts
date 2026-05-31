// display instructions
//   run nextcloud_sftp.yml howto
import { expr, type Playbook, rawTmpl, tmpl } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    vars: {
      groupfolder_name: "PAUL",
      groupfolder_id: 27,
      groupfolder_dir: tmpl`/disk/data/nextcloud/data/__groupfolders/${
        rawTmpl("{{ groupfolder_id}}")
      }`,
      host_uid: 33,
      host_user: "www-data",
      sftp_image: "docker.io/atmoz/sftp:debian",
      sftp_user: "nc_paul_upload",
      sftp_exec: tmpl`/usr/libexec/sftp-only-${expr("sftp_user")}`,
      sftp_dirs: [
        {
          src: tmpl`${rawTmpl("{{ groupfolder_dir}}")}/WP1/Data`,
          dst: "WP1_Data",
        },
        {
          src: tmpl`${rawTmpl("{{ groupfolder_dir}}")}/WP2/Data`,
          dst: "WP2_Data",
        },
        {
          src: tmpl`${rawTmpl("{{ groupfolder_dir}}")}/WP3/Data`,
          dst: "WP3_Data",
        },
        {
          src: tmpl`${rawTmpl("{{ groupfolder_dir}}")}/WP4/Data`,
          dst: "WP4_Data",
        },
      ],
      sftp_port: 60022,
    },

    handlers: [
      {
        name: "reload sshd",
        systemd: {
          name: "sshd",
          state: "reloaded",
        },
      },
    ],

    tasks: [
      {
        name: "Retrieve groupfolder id",
        check_mode: false,
        shellfact: {
          exec:
            tmpl`occ groupfolder:list --output json | jq  '.[] | select(.mount_point == "${
              expr("groupfolder_name")
            }") | .id'`,
          fact: "_gfid",
        },
      },
      {
        name: "Make sure we're dealing with the correct groupfolder",
        assert: {
          that: "(_gfid | int) == groupfolder_id",
        },
      },
      {
        name: "Check that all the src directories exists",
        stat: {
          path: expr("item.src"),
        },
        register: "r",
        failed_when: "not r.stat.exists",
        loop: expr("sftp_dirs"),
      },
      {
        name: "Retrieve passwd data for www-data user",
        getent: {
          database: "passwd",
          key: "www-data",
        },
        register: "getent",
      },
      {
        name: "Check our assumptions about www-data uid",
        assert: {
          that:
            "(getent.ansible_facts.getent_passwd[host_user][1] | int) == host_uid",
        },
      },
      {
        name: "Create sftp user",
        user: {
          name: expr("sftp_user"),
          uid: expr("host_uid"),
          group: expr("host_uid"),
          password: expr(
            "vault_nc_paul_upload_password |\n   password_hash('sha512', vault_pw_salt)",
          ),
          non_unique: true,
          create_home: true,
        },
      },
      {
        name: "Create passwd file",
        become: true,
        become_user: expr("sftp_user"),
        args: {
          chdir: tmpl`/home/${rawTmpl("{{sftp_user}}")}`,
          creates: tmpl`/home/${rawTmpl("{{sftp_user}}")}/passwd`,
        },
        shell: tmpl`grep ${rawTmpl("{{sftp_user}}")} /etc/passwd > passwd`,
      },
      {
        name: "Create sftp command script",
        tags: "script",
        copy: {
          dest: expr("sftp_exec"),
          mode: "+x",
          content: `#!/bin/bash

# echo "### environment ###"  >> /tmp/sftp.log
# env >> /tmp/sftp.log
# echo "### starting ###" >> /tmp/sftp.log
# exec > >(tee -ai /tmp/sftp.log)
# exec 2>&1

exec bwrap \\
  --proc /proc \\
  --dev /dev \\
  --ro-bind /usr/lib /usr/lib \\
  --symlink /usr/lib /lib \\
  --ro-bind /usr/lib64 /usr/lib64 \\
  --symlink /usr/lib64 /lib64 \\
  --ro-bind /usr/lib/openssh/sftp-server /usr/lib/openssh/sftp-server \\
  --ro-bind ./passwd /etc/passwd \\
  {% for d in sftp_dirs %}
  {{- "--bind %s /upload/%s" % (d.src, d.dst) }} \\
  {% endfor -%}
  --chdir /upload \\
  /usr/lib/openssh/sftp-server
`,
        },
      },
      {
        name: "Add user-specific config to sshd",
        blockinfile: {
          marker: "# {mark} ansible / nc_paul_upload",
          insertafter: "EOF",
          path: "/etc/ssh/sshd_config",
          block: `# https://bugzilla.mindrot.org/show_bug.cgi?id=3122
# When using sshd 8.2 (ubuntu 20.04), this config cannot be in an
# include file.
Match User {{ sftp_user }}
  PasswordAuthentication yes
  ForceCommand {{ sftp_exec }}
Match All
`,
        },
        notify: "reload sshd",
      },
      {
        name: "Create nextcloud rescan script",
        copy: {
          dest: "/usr/libexec/nextcloud-paul-upload-scan.sh",
          mode: "+x",
          content: `#!/bin/bash
while :; do
    /usr/local/sbin/occ groupfolders:scan -- {{ groupfolder_id }}
    sleep 120
done
`,
        },
        register: "_script",
      },
      {
        name: "Create systemd service file",
        copy: {
          dest: "/etc/systemd/system/nextcloud-paul-upload-scan.service",
          content: `[Service]
User=root
WorkingDirectory=/docker/nextcloud
ExecStart={{ _script.dest }}

[Unit]
Description=Rescan nextcloud groupfolder {{ groupfolder_id }}
# Shut down when the user logs out.
PartOf=user@{{ host_uid }}.service

[Install]
# Start when any user with this uid logs in. Note that processes for
# www-data will be active, but www-data won't be logged in.
WantedBy=user@{{ host_uid }}.service
`,
        },
      },
      {
        name: "Test logging in to sftp",
        tags: "login",
        delegate_to: "localhost",
        expect: {
          command: tmpl`sftp -P 60022 -oPreferredAuthentications=password ${
            expr("sftp_user")
          }@fsicos2.icos-cp.eu`,
          responses: {
            "password:": expr("vault_nc_paul_upload_password"),
            "sftp>": [
              "ls -1",
              "quit",
            ],
          },
        },
        register: "expect",
        changed_when: false,
      },
      {
        name: "Check directories",
        tags: "login",
        assert: {
          that: [
            'expect.stdout_lines[-2] == "WP4_Data"',
            'expect.stdout_lines[-3] == "WP3_Data"',
            'expect.stdout_lines[-4] == "WP2_Data"',
            'expect.stdout_lines[-5] == "WP1_Data"',
          ],
        },
        changed_when: false,
      },
      {
        name: "Display instructions",
        tags: "howto",
        debug: {
          msg: `# ssh config is as follows
host sftp-paul-nextcloud
  hostname fsicos2.icos-cp.eu
  port {{ sftp_port }}
  user {{ sftp_user }}
  preferredauthentications password

# With that config in place, the command used to connect looks like:
sftp sftp-paul-nextcloud

# Without a ssh config, use the longer command:
sftp -P 60022 -oPreferredAuthentications=password {{ sftp_user }}@fsicos2.icos-cp.eu
# The password is {{ vault_nc_paul_upload_password }}
`,
        },
      },
    ],
  },
] satisfies Playbook;
