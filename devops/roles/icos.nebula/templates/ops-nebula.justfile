#!/usr/bin/env -S just --working-directory . --justfile

set positional-arguments
set shell := ['/bin/bash', '-cu']

# the host suffix for hosts in this nebula network
suffix := "{{{nebula_interface}}}"



# META
@_default:
    just --list --unsorted --justfile {{justfile()}}



# MISC
# show installed version of nebula
[group('misc')]
version:
    nebula -version

# apt install dependencies for this justfile
[group('misc')]
deps:
    # iperf3 for speed test and jq for ssh debugging
    apt install iperf3 jq

# show certificate
[group('misc')]
cert:
    nebula-cert print -path {{{nebula_etc_dir}}}/host.crt

# show ca
[group('misc')]
ca:
    nebula-cert print -path {{{nebula_etc_dir}}}/ca.crt

{% if nebula_stats_enable %}
# retrive prometheus stats
[group('misc')]
stats:
    wget http://127.0.0.1:{{{nebula_stats_port}}}/metrics -qO -
{% endif %}


# SYSTEMD SERVICE
# check status of systemd service
[group('service')]
status:
    systemctl status nebula.service

# tail logs
[group('service')]
tail:
    journalctl -n 30 -f -u nebula.service

# show listening ports
[group('service')]
ports:
    ss -stulpn | grep nebula



# SSH DEBUG CONSOLE
# connect to admin interface using ssh
[group('debug console')]
ssh *args:
    ssh -i {{{nebula_ssh_key}}} -p {{{nebula_ssh_port}}} admin@127.0.0.1 {{args}}

# print-tunnel for HOST.nebula
[group('debug console')]
print host:
    #!/bin/bash
    which jq >/dev/null || just deps
    ip=$(awk '$2 == "{{host}}.nebula" { print $1 }' /etc/hosts)
    just --justfile {{justfile()}} ssh print-tunnel $ip | jq



# IPERF SPEED TEST
# start iperf3 server
[group('speed')]
iperf-listen name=`hostname`:
    iperf3 -B {{name}}.{{suffix}} -s

# start iperf3 client
[group('speed')]
iperf-connect name:
    iperf3 -c {{name}}.{{suffix}}



# DEBUG LOGGING
# set loglevel and maybe restart
[group('debug')]
_loglevel new:
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
[group('debug')]
debug-on:
    just --justfile {{justfile()}} _loglevel debug

# disable debugging
[group('debug')]
debug-off:
    just --justfile {{justfile()}} _loglevel info



# USED BY ANSIBLE
# show status of certificate
[group('ansible')]
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
