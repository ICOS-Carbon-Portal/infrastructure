# Standard library imports
import sys
import os

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
c.DockerSpawner.allowed_images = [
    'registry.icos-cp.eu/exploredata.test.icos-notebooks',
    'registry.icos-cp.eu/exploredata.test.summer-school',
    'registry.icos-cp.eu/exploredata.test.pylib-examples',
]
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


nbs = {
    'icos_jupyter': [
        'curve_fitting_obspack.ipynb',
        'ecosystem_site_anomaly_visualization.ipynb',
        'icos_atmObs_statistics.ipynb',
        'radiocarbon.ipynb',
        'station_characterization.ipynb',
    ],
    'pylib_examples': [
        'ex1_data.ipynb',
        'ex1a_atmo_data.ipynb',
        'ex1b_eco_data.ipynb',
        'ex1c_ocean_data.ipynb',
        'ex2_station.ipynb',
        'ex3_multisource.ipynb',
        'ex4_collection.ipynb',
        'ex5_sparql.ipynb',
        'ex6a_STILT_find.ipynb',
        'ex6b_STILT_footprint_animation.ipynb',
        'ex7_ObsPackData.ipynb',
        'how_to_authenticate.ipynb',
    ]
}

image_map = {
    'icos-notebooks:latest': os.environ['ICOS_NOTEBOOKS_IMAGE'],
    'pylib-examples:latest': os.environ['PYLIB_EXAMPLES_IMAGE'],
    'summer-school:latest': os.environ['SUMMER_SCHOOL_IMAGE'],
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
            image_from_form, notebook = form_data.get('env')[0].split('&nb=')
            options['image'] = image_map[image_from_form]
            if notebook in nbs['icos_jupyter']:
                options['notebook'] = f'/lab/tree/icos-jupyter-notebooks/{notebook}'
            elif notebook in nbs['pylib_examples']:
                options['notebook'] = f'/lab/tree/{notebook}'
            elif notebook == 'ICOS_flasksampling_fossilfuel.ipynb':
                options['notebook'] = (
                    f'/lab/tree/project-jupyter-notebooks/RINGO-T1.3/{notebook}'
                )
            elif notebook == 'city-characterization-tool':
                options['notebook'] = (
                    f'/lab/tree/project-jupyter-notebooks/city-characterization-tool/city_characteristic_analysis.ipynb'
                )
            elif notebook == 'network-view-tool':
                options['notebook'] = (
                    f'/lab/tree/project-jupyter-notebooks/network-view-tool/network_view.ipynb'
                )
            elif notebook == 'envrifair_winterschool':
                options['notebook'] = (
                    f'/lab/tree/project-jupyter-notebooks/envrifair-winterschool/map'
                )
            elif notebook == 'otc_data_reduction_workshop':
                options['notebook'] = (
                    f'/lab/tree/project-jupyter-notebooks/otc-data-reduction-workshop'
                )
            elif notebook == 'summer_school':
                pass
            else:
                raise ValueError('Wrong or no image selected')

        return options

    async def start(self):
        if 'image' not in self.user_options:
            raise ValueError(
                'You must select an environment before starting the server.'
            )
        self.image = self.user_options['image']
        if 'notebook' in self.user_options.keys():
            self.default_url = self.user_options['notebook']
        return await super().start()


c.JupyterHub.spawner_class = CustomDockerSpawner
