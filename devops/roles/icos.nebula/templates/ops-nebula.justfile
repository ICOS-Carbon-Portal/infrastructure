#!/usr/bin/env -S just --working-directory . --justfile

# the host suffix for hosts in this nebula network
suffix := "((nebula_interface))"

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
    ssh -i ((nebula_ssh_key)) -p ((nebula_ssh_port)) admin@127.0.0.1 {{args}}

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
    #!/usr/bin/bash
    set -Eueo pipefail

    cd ((nebula_etc_dir))
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
