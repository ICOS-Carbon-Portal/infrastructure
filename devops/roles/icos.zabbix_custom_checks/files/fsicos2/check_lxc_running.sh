#!/bin/bash
###############################################
#
# check_lxc_running.sh
# Returns number of running LXC containers
#
###############################################

# Set HOME to avoid snap warning
export HOME=/root

/snap/bin/lxc list --format=csv -c ns 2>/dev/null | grep -c "RUNNING" || echo 0

