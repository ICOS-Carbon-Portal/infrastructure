#!/usr/bin/env -S just --working-directory . --justfile

# the host suffix for hosts in this nebula network
suffix := "{{{nebula_interface}}}"

# META
@_default:
    just --list --unsorted --justfile {{justfile()}}

# apt install dependencies for this justfile
deps:
    # iperf3 for speed test and jq for ssh debugging
    apt install iperf3 jq


# SYSTEMD SERVICE
# check status of systemd service
status:
    systemctl status nebula.service

# tail logs
tail:
    journalctl -n 30 -f -u nebula.service


# SSH DEBUG CONSOLE
# connect to admin interface using ssh
ssh *args:
    ssh -i {{{nebula_ssh_key}}} -p {{{nebula_ssh_port}}} admin@127.0.0.1 {{args}}

# print-tunnel for HOST.nebula
print host:
    #!/bin/bash
    which jq >/dev/null || just deps
    ip=$(awk '$2 == "{{host}}.nebula" { print $1 }' /etc/hosts)
    just --justfile {{justfile()}} ssh print-tunnel $ip | jq


# IPERF SPEED TEST
# start iperf3 server
iperf-listen myhostname=`hostname`:
    iperf3 -B {{myhostname}}.{{suffix}} -s

# start iperf3 client
iperf-connect shortname:
    iperf3 -c {{shortname}}.{{suffix}}


# DEBUG LOGGING
# set loglevel and maybe restart
loglevel new:
    #!/bin/bash
    set -Eueo pipefail

    cd {{{nebula_etc_dir}}}
    h1=$(sha1sum config.yml)

    sed -i -r 's/^(\s+level:\s+)\w+$/\1{{new}}/' config.yml
    h2=$(sha1sum config.yml)

    if [[ h1 == h2 ]]; then
      echo "loglevel already at {{new}}"
    else
      echo "loglevel changed, restarting nebula"
      systemctl restart nebula
    fi

# enable debugging
debug-on:
    just --justfile {{justfile()}} loglevel debug

# disable debugging
debug-off:
    just --justfile {{justfile()}} loglevel info



# USED BY ANSIBLE
# show status of certificate
cert-check maxdays="90":
    #!/bin/bash
    set -Eueo pipefail
    cd {{{nebula_etc_dir}}}

    # a new certificate has been written, let's replace it
    if [[ -f new.crt ]]; then
      echo "creating backup of current key/cert"
      [[ -f host.crt ]] && mv host.crt old.crt
      [[ -f host.key ]] && mv host.key old.key
      mv new.key host.key
      mv new.crt host.crt
      rm -f new.pub
      echo "need to restart"
      exit 0
    fi

    # a new public key exists, it needs to be signed
    if [[ -f new.pub ]]; then
       echo "need to sign"
       exit 0
    fi

    # finally check if the current certificate is expiring
    if [[ -f host.crt ]]; then
      # expiration datetime, eg '2024-11-11T18:42:50+01:00'
      d=`nebula-cert print -path host.crt -json | jq -r .details.notAfter`
      # expiration in epoch seconds, e.g 1731346970
      later=`date -d "$d" '+%s'`
      # current epoch seconds
      now=`date '+%s'`
      # days until host.crt expires
      days=$(( (later - now) / 86400 ))
      if (( days >= {{maxdays}} )); then
        echo "current cert expires in $days days, is ok"
        exit 0
      else
        echo "current cert expires in $days, need a new one"
      fi
    fi

    # either the cert was old, or no cert existing
    nebula-cert keygen -out-key new.key -out-pub new.pub
    echo "need to sign"
