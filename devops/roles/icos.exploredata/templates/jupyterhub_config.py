import sys
import os

# CONFIGURATION OF THE HUB

# The ip address for the Hub process to *bind* to.
c.JupyterHub.hub_ip = '0.0.0.0'
# c.JupyterHub.log_level = logging.DEBUG

# The host name that notebooks will use to connect to the hub. In our case,
# this is assigned to the hub image by docker-compose.
c.JupyterHub.hub_connect_ip = 'hub'

# We handle authentication in the reverse proxy
c.JupyterHub.authenticate_prometheus = False

# Shuts down all user servers on logout
c.JupyterHub.shutdown_on_logout = True

# https://jupyterhub.readthedocs.io/en/stable/reference/templates.html
c.JupyterHub.template_paths = ["/srv/jupyterhub/templates"]

{% if exploredata_type == "prod" %}
# https://github.com/jupyterhub/jupyterhub-idle-culler
c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'admin': True,
        'command': [
            sys.executable,
            '-m', 'jupyterhub_idle_culler',
            '--timeout=3660'
        ],
    }]
{% endif %}

# AUTHENTICATION

# The DummyAuthenticator allows any username along with a hardcoded password.
c.JupyterHub.authenticator_class = 'jupyterhub.auth.DummyAuthenticator'
c.DummyAuthenticator.password = os.environ["PASSWORD"]

# This tells jupyterhub that "root" is an admin user. That's supposed to give
# the root user an admin panel, which I didn't get to work (because of
# DummyAuthenticator?). What it does enable however, is executing "jupyterhub
# token" in the hub container.
c.Authenticator.admin_users = set(['root'])

# We then say that root cannot login over the web. Executing "jupyterhub token"
# will still work.
c.Authenticator.blacklist = ['root']


# CONFIGURATION OF THE NOTEBOOK CONTAINERS
# https://github.com/jupyterhub/dockerspawner/blob/master/dockerspawner/dockerspawner.py

c.JupyterHub.spawner_class = 'docker'
c.DockerSpawner.image = os.environ["NOTEBOOK_IMAGE"]
c.DockerSpawner.network_name = os.environ["NETWORK_NAME"]
c.DockerSpawner.notebook_dir = '/home/jovyan'
c.DockerSpawner.remove_containers = True
c.DockerSpawner.debug = True
c.DockerSpawner.read_only_volumes = {
    '/data/stiltweb/stations' : "/data/stiltweb/stations",
    '/data/stiltweb/slots'    : "/data/stiltweb/slots",
    '/data'                   : '/data'
}


# RESTRICTIONS ON THE NOTEBOOKS

# Maximum number of concurrent named servers that can be created by a user at a
# time.
c.JupyterHub.named_server_limit_per_user = 1

# Maximum number of bytes a single-user notebook server is allowed to use.
c.Spawner.mem_limit = '2G'

# Maximum number of cpu-cores a single-user notebook server is allowed to use.
c.Spawner.cpu_limit = 1

# Maximum number of concurrent servers that can be active at a time.
c.JupyterHub.active_server_limit = {{ exploredata_max_notebooks }}

# Interval (in seconds) at which to update last-activity timestamps.
# This is set much more aggressively than in the default configuration so that
# we quickly can shut down idle servers.
c.JupyterHub.last_activity_interval = 300

# The override configuration file doesn't have to exist.
load_subconfig(os.path.join(os.path.dirname(__file__),
                            'jupyterhub_config_override.py'))
