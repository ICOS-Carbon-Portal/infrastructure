# https://hub.docker.com/r/jupyterhub/jupyterhub/tags
# <2024-08-15 Thu> jupyterhub:5.1.0
FROM jupyterhub/jupyterhub:latest@sha256:a2eea3d5181c4c765a289ced37c6cc7d6272e617ef646fa97102b39b6696537a

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && apt-get install -qy iproute2 curl git tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN pip install git+https://github.com/jupyterhub/dockerspawner.git


# COPY cull_idle_servers.py /srv/jupyterhub/
# COPY jupyterhub_config.py /srv/jupyterhub/
