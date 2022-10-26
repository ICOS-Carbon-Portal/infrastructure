# https://hub.docker.com/r/jupyterhub/jupyterhub/tags
# FROM jupyterhub/jupyterhub:1.3

# <2022-10-24> jupyterhub:3.0.0
FROM jupyterhub/jupyterhub:latest@sha256:15ad3278c339227d4aa20c93a91450c7d283d53640dd390eb361a819e3dfc14e


ENV DEBIAN_FRONTEND=noninteractive

RUN pip install dockerspawner jupyterhub-idle-culler
RUN apt update && apt install -y iproute2 curl tzdata

RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
