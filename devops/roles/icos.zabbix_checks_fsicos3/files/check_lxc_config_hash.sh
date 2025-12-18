#!/bin/bash

####################################################
# Docker status checker in LXC container
# OUTPUT: 1 = changed, 0 = unchanged.
####################################################

CURRENT_HASH=$(sudo lxc config show exploredata | md5sum | awk '{print $1}')
BASELINE_HASH=$(cat /etc/zabbix/scripts/hash-keys/exploredata-hash)


if [ "$CURRENT_HASH" = "$BASELINE_HASH" ]; then
    # Configuration unchanged
    echo 0
else
    # Configuration has changed
    echo 1
fi

