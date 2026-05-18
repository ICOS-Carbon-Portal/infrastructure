#!/bin/bash

###############################################
# check_mounts.sh
#
# Paramter with correct value needed.
# Returns:
#   0 - Correct numbers of nfs mounts
#   1 - NFS mount(s) is missing.
#
###############################################

EXPECTED=$1
ACTUAL=$(df -P 2>/dev/null | grep ':' | wc -l)

if [ "$ACTUAL" -eq "$EXPECTED" ]; then
    echo "OK: $ACTUAL mount points found (expected: $EXPECTED)"
    exit 0
else
    echo "CRITICAL: $ACTUAL mount points found (expected: $EXPECTED)"
    exit 1
fi

exit 0

