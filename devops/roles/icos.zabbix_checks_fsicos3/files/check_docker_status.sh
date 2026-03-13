#!/bin/bash

####################################################
# Docker status checker in LXC container
# OUTPUT: 1 = running, 0 = not running
####################################################

LXC_BIN="/snap/bin/lxc"
LXC_CONTAINER=$1
DOCKER_CONTAINER=$2


if [ -z "$DOCKER_CONTAINER" ]; then
	echo "*** Missing parameter"
	exit 1
fi

STATE=$(sudo $LXC_BIN exec $LXC_CONTAINER -- bash -lc "docker inspect -f '{{.State.Status}}' '$DOCKER_CONTAINER'" 2>/dev/null)


if [ "$STATE" = "running" ]; then
	echo 1
else
	echo 0
fi

exit 0
