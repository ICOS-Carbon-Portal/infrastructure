# Overview

This role will install the OnlyOffice DocumentServer as a docker container
proxied by a host nginx.

# Purpose

It is meant for integration with Nextcloud. That's also how it was tested. It
doesn't really need any storage of its own.

# Assumptions

* That docker is installed.
* That nginx is installed.

# Known bugs

The below was true for 5.3.x; we are now up to 9.0.4, so unsure if same issues apply.

* The OnlyOffice image is very complex. The single container will use
  supervised(1) to start:
  * postgres 9.5 (i.e, an older version)
  * redis
  * nginx (for internal proxying)
  * cron
  * rabbitmq (a message-queue in erlang)
  * a bunch of node.js services
* It doesn't support running as a different user
  * It'll start some services as other users and some as root

# Resources
+ [Onlyoffice docker installation](https://github.com/ONLYOFFICE/Docker-DocumentServer/blob/master/README.md#running-onlyoffice-document-server-using-https)
+ [Community version (the one we're running)](https://helpcenter.onlyoffice.com/server/docker/community/index.aspx)
+ [The official forum](http://dev.onlyoffice.org/)
+ [Docker images and tags](https://hub.docker.com/r/onlyoffice/documentserver/)
+ [Nextcloud integration](https://api.onlyoffice.com/editors/nextcloud)

# Upgrading OnlyOffice

To ensure data is not lost, prepare for shutdown. On fsicos2:

`docker exec onlyoffice /usr/bin/documentserver-prepare4shutdown.sh`

This script may take up to 5 minutes.

Update the version in `defaults/main.yml`. Then run the ansible playbook; the command below runs in check mode, so remove the `-C` flag to execute the command:

`icos play nextcloud -t onlyoffice_docker -DC`
