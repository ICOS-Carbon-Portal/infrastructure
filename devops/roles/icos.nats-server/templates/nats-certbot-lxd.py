#!/usr/bin/python3
# See `certbot --help renew` for information about hook runtime environment.
# $RENEWED_LINEAGE == "/etc/letsencrypt/live/example.com"
# $RENEWED_DOMAINS == "example.com www.example.com"

import subprocess
import sys
import os

LIVE = '/etc/letsencrypt/live/{{ certbot_name }}'
FILES = [f'{LIVE}/fullchain.pem', f'{LIVE}/privkey.pem']
LXC = '/snap/bin/lxc'

RENEWED_DOMAINS = set(os.environ.get('RENEWED_DOMAINS', '').split())
MY_DOMAINS = set({{ certbot_domains }})
RELOAD_CMD = 'chown nats:nats /opt/nats/*.pem && systemctl reload nats'
    
if sys.stdin.isatty() or MY_DOMAINS & RENEWED_DOMAINS:
    # FILES will point to fullchainX.pem etc, but we want to copy them without
    # the number suffix, hence we need to do it as a loop.
    for name in FILES:
        if 'privkey' in name:
            dest_name = 'privkey.pem'
        else:
            dest_name = 'fullchain.pem'
        subprocess.run([LXC, 'file', 'push',
                        name, f"{{ nats_cert_dest }}/{dest_name}"], check=1)
    subprocess.run([LXC, 'exec', '{{ nats_lxd_name }}', '--',
                    'bash', '-c', RELOAD_CMD], check=1)
