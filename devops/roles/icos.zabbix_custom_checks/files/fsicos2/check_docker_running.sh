#!/bin/bash
###############################################
# check_docker_num.sh - Zabbix version
# Returns number of running docker containers
###############################################
docker ps -q 2>/dev/null | wc -l
