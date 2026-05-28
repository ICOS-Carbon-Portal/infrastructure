-- Auto-generated from nextcloud_sftp.yml

[
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
        { name = "reload sshd", systemd = { name = "sshd", state = "reloaded" } }
    ]
    , tasks = [
        {
          name = "Retrieve groupfolder id",
          check_mode = Some False,
          shellfact = Some {
            exec = "occ groupfolder:list --output json | jq  '.[] | select(.mount_point == \"{{ groupfolder_name }}\") | .id'"
          , fact = "_gfid"
        },
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Make sure we're dealing with the correct groupfolder",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = Some { that = "(_gfid | int) == groupfolder_id" },
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Check that all the src directories exists",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = Some { path = "{{ item.src }}" },
          register = Some "r",
          failed_when = Some "not r.stat.exists",
          loop = Some "{{ sftp_dirs }}",
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Retrieve passwd data for www-data user",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = Some "getent",
          failed_when = None Text,
          loop = None Text,
          getent = Some { database = "passwd", key = "www-data" },
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Check our assumptions about www-data uid",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = Some {
            that = "(getent.ansible_facts.getent_passwd[host_user][1] | int) == host_uid"
        },
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Create sftp user",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = Some {
            name = "{{ sftp_user }}"
          , uid = "{{ host_uid }}"
          , group = "{{ host_uid }}"
          , password = ''
            {{ vault_nc_paul_upload_password |
               password_hash('sha512', vault_pw_salt) }}
          ''
          , non_unique = True
          , create_home = True
        },
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Create passwd file",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = Some True,
          become_user = Some "{{ sftp_user }}",
          args = Some { chdir = "/home/{{sftp_user}}", creates = "/home/{{sftp_user}}/passwd" },
          shell = Some "grep {{sftp_user}} /etc/passwd > passwd",
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Create sftp command script",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = Some "script",
          copy = Some {
            dest = "{{ sftp_exec }}"
          , mode = Some "+x"
          , content = ''
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

          ''
        },
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Add user-specific config to sshd",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = Some {
            marker = "# {mark} ansible / nc_paul_upload"
          , insertafter = "EOF"
          , path = "/etc/ssh/sshd_config"
          , block = ''
            # https://bugzilla.mindrot.org/show_bug.cgi?id=3122
            # When using sshd 8.2 (ubuntu 20.04), this config cannot be in an
            # include file.
            Match User {{ sftp_user }}
              PasswordAuthentication yes
              ForceCommand {{ sftp_exec }}
            Match All

          ''
        },
          notify = Some "reload sshd",
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Create nextcloud rescan script",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = Some "_script",
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = Some {
            dest = "/usr/libexec/nextcloud-paul-upload-scan.sh"
          , mode = Some "+x"
          , content = ''
            #!/bin/bash
            while :; do
                /usr/local/sbin/occ groupfolders:scan -- {{ groupfolder_id }}
                sleep 120
            done

          ''
        },
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Create systemd service file",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = None Text,
          copy = Some {
            dest = "/etc/systemd/system/nextcloud-paul-upload-scan.service"
          , mode = None Text
          , content = ''
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

          ''
        },
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = None ({ msg : Text })
        }
      , {
          name = "Test logging in to sftp",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = Some "expect",
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = Some "login",
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = Some "localhost",
          expect = Some {
            command = "sftp -P 60022 -oPreferredAuthentications=password {{ sftp_user }}@fsicos2.icos-cp.eu"
          , responses = {
              `password:` = "{{ vault_nc_paul_upload_password }}"
            , `sftp>` = [ "ls -1", "quit" ]
          }
        },
          changed_when = Some False,
          debug = None ({ msg : Text })
        }
      , {
          name = "Check directories",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = Some {
            that = [
              "expect.stdout_lines[-2] == \"WP4_Data\""
            , "expect.stdout_lines[-3] == \"WP3_Data\""
            , "expect.stdout_lines[-4] == \"WP2_Data\""
            , "expect.stdout_lines[-5] == \"WP1_Data\""
          ]
        },
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = Some "login",
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = Some False,
          debug = None ({ msg : Text })
        }
      , {
          name = "Display instructions",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          `assert` = None ({ that : List Text }),
          stat = None ({ path : Text }),
          register = None Text,
          failed_when = None Text,
          loop = None Text,
          getent = None ({ database : Text, key : Text }),
          user = None ({ name : Text, uid : Text, group : Text, password : Text, non_unique : Bool, create_home : Bool }),
          become = None Bool,
          become_user = None Text,
          args = None ({ chdir : Text, creates : Text }),
          shell = None Text,
          tags = Some "howto",
          copy = None ({ dest : Text, mode : Optional Text, content : Text }),
          blockinfile = None ({ marker : Text, insertafter : Text, path : Text, block : Text }),
          notify = None Text,
          delegate_to = None Text,
          expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } }),
          changed_when = None Bool,
          debug = Some {
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
        }
        }
    ]
  }
]
