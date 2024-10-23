# The geospatial package includes HDF-5
FROM rocker/geospatial

# https://docs.docker.com/develop/develop-images/guidelines/
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
    subversion \
    csh \
    libnetcdf-dev \
    libnetcdff-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
# Check this page if links to packages change:
#   https://cran.r-project.org/web/packages/available_packages_by_name.html
WORKDIR /opt/build
RUN R -e "install.packages('dotCall64',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('spam',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('fields',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# Use bash in order to get brace expansion
RUN ["/bin/bash", "-c", "ln -s /usr/lib/x86_64-linux-gnu/libnetcd{f,ff}.so /usr/lib/"]

# Check out the STILT project and compile it.
ARG JENASVNUSER
ARG JENASVNPASSWORD

# <2024-07-15> As of today, revision 751 is the best revision.
ARG JENASVNREVISION=751

WORKDIR /opt/STILT_svn
RUN svn \
    --username ${JENASVNUSER} \
    --password ${JENASVNPASSWORD} \
    --non-interactive checkout \
    --revision ${JENASVNREVISION} \
    https://projects.bgc-jena.mpg.de/STILT/svn/trunk

WORKDIR /opt/STILT_modelling/
RUN cp -R /opt/STILT_svn/trunk/stiltR .
COPY setup.sh .
RUN chmod +x setup.sh && ./setup.sh && rm setup.sh

RUN echo ${JENASVNREVISION} && touch ./version_$JENASVNREVISION

WORKDIR /opt/STILT_svn/trunk/merged_stilt_hysplit
COPY Makefile .
RUN make
RUN mv hymodelc /opt/STILT_modelling/

WORKDIR /opt/STILT_modelling/stiltR/shlib
COPY build.sh .
