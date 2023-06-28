restapi:
	@echo https://mailman.readthedocs.io/en/latest/src/mailman/rest/docs/rest.html
	@echo "http://{{ mailman_core_ipv4 }}:{{ mailman_rest_port }}/rest/3.1/system/versions"

weblog:
	bash -c 'tail -f volumes/web/logs/{mailmanweb,uwsgi}.log /var/log/nginx/{mailman,error}.log'

maillog:
	bash -c 'tail -f /var/log/mail.log volumes/core/var/logs/*.log'

fail2ban:
	fail2ban-client status; fail2ban-client status postfix-auth
