# https://github.com/maxking/docker-mailman/blob/master/web/mailman-web/settings.py

ALLOWED_HOSTS = [
    "localhost",
    "mailman-web",
    "{{ mailman_web_ipv4 }}",
    {% for host in mailman_domains -%}
    "{{ host }}",
    {% endfor %}
]

{% if mailman_rest_pass is defined -%}
MAILMAN_REST_API_USER = "{{ mailman_rest_user }}"
MAILMAN_REST_API_PASS = "{{ mailman_rest_pass }}"
{% endif -%}

# https://github.com/maxking/docker-mailman/tree/main/web#disable-social-auth
# This will remove all "login with google" etc buttons the web page.
MAILMAN_WEB_SOCIAL_AUTH = []
