# https://hub.docker.com/r/jupyterhub/jupyterhub/tags
# <2021-05-13> jupyterhub:1.4.1
# FROM jupyterhub/jupyterhub:1.3@sha256:108d14a6ed37371e0f5bf55831e0228090dac2afbb15f0219d60a270d91da1e8

# <2021-10-04 mån> jupyterhub:1.4.2
FROM jupyterhub/jupyterhub:1.3@sha256:35edcf1fcb913f30383f14dd30b7211d304de02e92accf094831e18ef4672756

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && apt-get install -qy iproute2 curl git tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN pip install git+https://github.com/jupyterhub/dockerspawner.git


# COPY cull_idle_servers.py /srv/jupyterhub/
# COPY jupyterhub_config.py /srv/jupyterhub/
