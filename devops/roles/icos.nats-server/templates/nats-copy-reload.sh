#!/bin/bash
# Copy files to a directory readable only by the nats user.
# See `certbot --help renew` for information about hook runtime environment.
# $RENEWED_LINEAGE == "/etc/letsencrypt/live/example.com"
# $RENEWED_DOMAINS == "example.com www.example.com"

set -Eueo pipefail

if [ "${RENEWED_LINEAGE:-}" = "/etc/letsencrypt/live/{{ nats_cert_name }}" ]; then
    cp $RENEWED_LINEAGE/{fullchain,privkey}.pem {{ nats_cert_dir }}
    chown {{ nats_user }}: {{ nats_cert_dir }}/*.pem
    # We pass along "noreload" when installing the script, to avoid the
    # chicken-and-egg problem of nats needing the certificates, but nats not
    # being present for reloading.
    if [ "${1:-}" != "noreload" ]; then
        systemctl reload nats
    fi
fi
