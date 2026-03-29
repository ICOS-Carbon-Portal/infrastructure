#!/bin/bash
#
# Script to check ping connectivity to specified host
# Returns 0 if ping is successful, 1 if failed
#
# Usage: ./check_ping_connectivity.sh <destination_host>

# Check if destination parameter is provided
if [ -z "$1" ]; then
    echo 1
    exit 1
fi

DESTINATION="$1"
PING_COUNT=3
PING_TIMEOUT=2

# Perform ping test
ping -c $PING_COUNT -W $PING_TIMEOUT "$DESTINATION" > /dev/null 2>&1

# Check exit status and return result
if [ $? -eq 0 ]; then
    echo 0  # Success
else
    echo 1  # Failed
fi
