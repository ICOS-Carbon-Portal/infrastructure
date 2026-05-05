# Standard library imports
import os
import sys

# Related third party imports
from dockerspawner import DockerSpawner


c = get_config()

# JupyterHub configuration
# Maximum number of concurrent servers that can be active at a time.
c.JupyterHub.active_server_limit = {{ exploredata_max_notebooks }}
# The dummy authenticator allows any username with a hardcoded password.
c.JupyterHub.authenticator_class = 'dummy'
c.DummyAuthenticator.password = os.environ['PASSWORD']
c.JupyterHub.hub_connect_ip = 'hub'
c.JupyterHub.hub_ip = '0.0.0.0'
# Interval (in seconds) at which to update last-activity timestamps.
# This is set much more aggressively than in the default configuration so that
# we quickly can shut down idle servers.
c.JupyterHub.last_activity_interval = 300
# Maximum concurrent named servers that can be created by a user.
c.JupyterHub.named_server_limit_per_user = 1
{% if exploredata_type == 'prod' %}
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
# Shuts down all user servers on logout
c.JupyterHub.shutdown_on_logout = True
# https://jupyterhub.readthedocs.io/en/stable/reference/templates.html
c.JupyterHub.template_paths = ['/srv/jupyterhub/templates']

# DockerSpawner configuration
# image_map and notebook_map are both derived from exploredata_notebooks:
# adding a notebook = one entry in defaults/main.yml, no edits here.
image_map = {
{% for n in exploredata_notebooks %}
    '{{ n.image }}:{{ n.tag }}': '{{ exploredata_registry }}/{{ exploredata_image_namespace }}.{{ n.image }}:{{ n.tag }}',
{% endfor %}
}

c.DockerSpawner.allowed_images = list(image_map.values())

c.DockerSpawner.debug = True
c.DockerSpawner.host_ip = '0.0.0.0'
c.DockerSpawner.network_name = os.environ['NETWORK_NAME']
c.DockerSpawner.notebook_dir = '/home/jovyan'
c.DockerSpawner.read_only_volumes = {
    '/data/stiltweb/stations' : '/data/stiltweb/stations',
    '/data/stiltweb/slots'    : '/data/stiltweb/slots',
    '/data'                   : '/data'
}
c.DockerSpawner.remove_containers = True
c.DockerSpawner.use_internal_ip = True

# Maximum number of bytes a single-user notebook server is allowed to use.
c.Spawner.mem_limit = '2G'
# Maximum number of cpu-cores a single-user notebook server is allowed to use.
c.Spawner.cpu_limit = 1

notebook_map = {
{% for n in exploredata_notebooks %}
    '{{ n.slug }}': '{{ n.path }}',
{% endfor %}
}


class CustomDockerSpawner(DockerSpawner):
    @staticmethod
    def options_form(spawner):
        template_path = '/srv/jupyterhub/templates/custom_options_form.html'
        with open(template_path, 'r') as f:
            return f.read()

    @staticmethod
    def options_from_form(form_data):
        options = {}
        if form_data:
            image, notebook = form_data.get('env')[0].split('&nb=')
            options['image'] = image_map[image]
            options['notebook'] = notebook_map[notebook]
        return options

    async def start(self):
        if 'image' not in self.user_options:
            raise ValueError('You must select an environment before starting the server.')
        self.image = self.user_options['image']
        if 'notebook' in self.user_options.keys():
            self.default_url = self.user_options['notebook']
        return await super().start()


c.JupyterHub.spawner_class = CustomDockerSpawner
