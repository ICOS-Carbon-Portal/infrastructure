# https://hub.docker.com/r/jupyterhub/jupyterhub/tags
# <2023-05-13> jupyterhub:4.0.0
# "403 : Forbidden '_xsrf' argument missing from POST" ... eh?
# FROM jupyterhub/jupyterhub:latest@sha256:b6c353d4a6cfc60def3ad42dbf5a3329aa53562e554b94285b39825ea488e4c4

# <2023-03-08> jupyterhub:3.1
FROM jupyterhub/jupyterhub:latest@sha256:ebe69134c17ee945bb7726570317f937810ddbbb1eed64f42821508cbcf38509

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && apt-get install -qy iproute2 curl git tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN pip install git+https://github.com/jupyterhub/dockerspawner.git


# COPY cull_idle_servers.py /srv/jupyterhub/
# COPY jupyterhub_config.py /srv/jupyterhub/
