# https://hub.docker.com/r/jupyterhub/jupyterhub/tags
FROM jupyterhub/jupyterhub:5.3.0@sha256:bf91ffe1d9ec516280304d27264786745fdbd4173ae0cedd6b8600b1152f15b2
ENV DEBIAN_FRONTEND=noninteractive
RUN pip install dockerspawner jupyterhub-idle-culler
RUN apt update && apt install -y iproute2 curl tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
