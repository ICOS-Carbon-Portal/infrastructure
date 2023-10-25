# STILT modeling software

Standard Docker image build file and docker-compose config file for STILT langrangian transport model software.
Build process requires username and password for access to MPI-BCG's SVN repository (in Jena).
Specify also the SVN revision number on which the model should be based.  
Edit the docker-compose config accordingly.

## First step: build the base STILT Docker image

## Second step: build the custom STILT Docker image that contains specific additions for the STILT Footprint Tool at ICOS CArbon Portal

## Saving a pre-build Docker image
`docker save <image> | gzip > <file>`

## Loading the pre-build base STILT Docker image
Run as a member of `docker` group or as root:
`wget -O- https://static.icos-cp.eu/share/docker/stilt/baseimage.tgz | gunzip -c | docker load`

