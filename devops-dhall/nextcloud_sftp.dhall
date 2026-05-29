-- Auto-generated from ../devops/nextcloud_sftp.yml

let Task = ./types/Task.dhall

in  [
    {
      hosts = "fsicos2"
    , vars = {
        groupfolder_name = "PAUL"
      , groupfolder_id = 27
      , groupfolder_dir = "/disk/data/nextcloud/data/__groupfolders/{{ groupfolder_id}}"
      , host_uid = 33
      , host_user = "www-data"
      , sftp_image = "docker.io/atmoz/sftp:debian"
      , sftp_user = "nc_paul_upload"
      , sftp_exec = "/usr/libexec/sftp-only-{{ sftp_user }}"
      , sftp_dirs = [
          { src = "{{ groupfolder_dir}}/WP1/Data", dst = "WP1_Data" }
        , { src = "{{ groupfolder_dir}}/WP2/Data", dst = "WP2_Data" }
        , { src = "{{ groupfolder_dir}}/WP3/Data", dst = "WP3_Data" }
        , { src = "{{ groupfolder_dir}}/WP4/Data", dst = "WP4_Data" }
      ]
      , sftp_port = 60022
    }
    , handlers = [
        Task::{
          name = Some "reload sshd",
          systemd = Some {
            name = Some "sshd",
            state = Some "reloaded",
            daemon_reload = None Bool,
            enabled = None Text,
            `daemon-reload` = None Text,
            status = None Text
        }
        }
    ]
    , tasks = [
        Task::{
          name = Some "Retrieve groupfolder id",
          check_mode = Some False,
          shellfact = Some {
            exec = "occ groupfolder:list --output json | jq  '.[] | select(.mount_point == \"{{ groupfolder_name }}\") | .id'",
            fact = "_gfid",
            bool = None Bool,
            list = None Bool
        }
        }
      , Task::{
          name = Some "Make sure we're dealing with the correct groupfolder",
          `assert` = Some { that = [ "(_gfid | int) == groupfolder_id" ], quiet = None Bool }
        }
      , Task::{
          name = Some "Check that all the src directories exists",
          stat = Some { path = "{{ item.src }}" },
          register = Some "r",
          failed_when = Some (Task.Poly_failed_when.Str "not r.stat.exists"),
          loop = Some (Task.Poly_loop.Str "{{ sftp_dirs }}")
        }
      , Task::{
          name = Some "Retrieve passwd data for www-data user",
          getent = Some { database = "passwd", key = "www-data" },
          register = Some "getent"
        }
      , Task::{
          name = Some "Check our assumptions about www-data uid",
          `assert` = Some {
            that = [ "(getent.ansible_facts.getent_passwd[host_user][1] | int) == host_uid" ],
            quiet = None Bool
        }
        }
      , Task::{
          name = Some "Create sftp user",
          user = Some {
            name = "{{ sftp_user }}",
            uid = Some "{{ host_uid }}",
            group = Some "{{ host_uid }}",
            password = Some ''
            {{ vault_nc_paul_upload_password |
               password_hash('sha512', vault_pw_salt) }}
          '',
            non_unique = Some True,
            create_home = Some "True",
            shell = None Text,
            home = None Text,
            password_lock = None Bool,
            groups = None ((List Text)),
            append = None Text,
            state = None Text,
            system = None Bool,
            generate_ssh_key = None Bool,
            remove = None Text
        }
        }
      , Task::{
          name = Some "Create passwd file",
          become = Some (Task.Poly_become.Bool True),
          become_user = Some "{{ sftp_user }}",
          args = Some {
            chdir = Some "/home/{{sftp_user}}",
            creates = Some "/home/{{sftp_user}}/passwd",
            executable = None Text,
            removes = None Text
        },
          shell = Some "grep {{sftp_user}} /etc/passwd > passwd"
        }
      , Task::{
          name = Some "Create sftp command script",
          tags = Some [ "script" ],
          copy = Some {
            dest = "{{ sftp_exec }}",
            mode = Some "+x",
            content = Some ''
            #!/bin/bash

            # echo "### environment ###"  >> /tmp/sftp.log
            # env >> /tmp/sftp.log
            # echo "### starting ###" >> /tmp/sftp.log
            # exec > >(tee -ai /tmp/sftp.log)
            # exec 2>&1

            exec bwrap \
              --proc /proc \
              --dev /dev \
              --ro-bind /usr/lib /usr/lib \
              --symlink /usr/lib /lib \
              --ro-bind /usr/lib64 /usr/lib64 \
              --symlink /usr/lib64 /lib64 \
              --ro-bind /usr/lib/openssh/sftp-server /usr/lib/openssh/sftp-server \
              --ro-bind ./passwd /etc/passwd \
              {% for d in sftp_dirs %}
              {{- "--bind %s /upload/%s" % (d.src, d.dst) }} \
              {% endfor -%}
              --chdir /upload \
              /usr/lib/openssh/sftp-server

          '',
            src = None Text,
            backup = None Bool,
            owner = None Text,
            group = None Text,
            force = None Text,
            validate = None Text
        }
        }
      , Task::{
          name = Some "Add user-specific config to sshd",
          blockinfile = Some {
            path = "/etc/ssh/sshd_config",
            create = None Bool,
            marker = "# {mark} ansible / nc_paul_upload",
            block = Some ''
            # https://bugzilla.mindrot.org/show_bug.cgi?id=3122
            # When using sshd 8.2 (ubuntu 20.04), this config cannot be in an
            # include file.
            Match User {{ sftp_user }}
              PasswordAuthentication yes
              ForceCommand {{ sftp_exec }}
            Match All

          '',
            insertafter = Some "EOF",
            insertbefore = None Text,
            state = None Text
        },
          notify = Some [ "reload sshd" ]
        }
      , Task::{
          name = Some "Create nextcloud rescan script",
          copy = Some {
            dest = "/usr/libexec/nextcloud-paul-upload-scan.sh",
            mode = Some "+x",
            content = Some ''
            #!/bin/bash
            while :; do
                /usr/local/sbin/occ groupfolders:scan -- {{ groupfolder_id }}
                sleep 120
            done

          '',
            src = None Text,
            backup = None Bool,
            owner = None Text,
            group = None Text,
            force = None Text,
            validate = None Text
        },
          register = Some "_script"
        }
      , Task::{
          name = Some "Create systemd service file",
          copy = Some {
            dest = "/etc/systemd/system/nextcloud-paul-upload-scan.service",
            mode = None Text,
            content = Some ''
            [Service]
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

          '',
            src = None Text,
            backup = None Bool,
            owner = None Text,
            group = None Text,
            force = None Text,
            validate = None Text
        }
        }
      , Task::{
          name = Some "Test logging in to sftp",
          tags = Some [ "login" ],
          delegate_to = Some "localhost",
          expect = Some {
            command = "sftp -P 60022 -oPreferredAuthentications=password {{ sftp_user }}@fsicos2.icos-cp.eu",
            responses = { `password:` = "{{ vault_nc_paul_upload_password }}", `sftp>` = [ "ls -1", "quit" ] }
        },
          register = Some "expect",
          changed_when = Some (Task.Poly_changed_when.Bool False)
        }
      , Task::{
          name = Some "Check directories",
          tags = Some [ "login" ],
          `assert` = Some {
            that = [
              "expect.stdout_lines[-2] == \"WP4_Data\""
            , "expect.stdout_lines[-3] == \"WP3_Data\""
            , "expect.stdout_lines[-4] == \"WP2_Data\""
            , "expect.stdout_lines[-5] == \"WP1_Data\""
          ],
            quiet = None Bool
        },
          changed_when = Some (Task.Poly_changed_when.Bool False)
        }
      , Task::{
          name = Some "Display instructions",
          tags = Some [ "howto" ],
          debug = Some (Task.Poly_debug.Record {
              msg = ''
              # ssh config is as follows
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

            ''
          })
        }
    ]
  }
]
