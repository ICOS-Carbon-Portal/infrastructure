#!/usr/bin/bash
{% if rdflog_backup_enable %}
exec icos-postgresql --bb {{ bbclient_one }} -- container rdflog --user rdflog
{% else %}
echo "This installation doesn't have bbclient backup enabled"
exit -1
{% endif %}
