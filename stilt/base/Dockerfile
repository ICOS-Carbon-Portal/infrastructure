FROM rocker/geospatial

# The geospatial package includes HDF-5

RUN apt-get update -y && apt-get upgrade -y

# Install extra packages
RUN apt-get install -y \
  # required to check out stilt source code
  subversion \
  # required by some of the stilt shell scripts
  csh

# Install R packages
# Check this page if links to packages change:
#   https://cran.r-project.org/web/packages/available_packages_by_name.html
WORKDIR /opt/build
RUN R -e "install.packages('dotCall64',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('spam',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('fields',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# Install NetCDF
RUN apt-get install -y libnetcdf-dev libnetcdff-dev
# Use bash in order to get brace expansion
RUN ["/bin/bash", "-c", "ln -s /usr/lib/x86_64-linux-gnu/libnetcd{f,ff}.so /usr/lib/"]

# Check out the STILT project and compile it.
ARG JENASVNUSER
ARG JENASVNPASSWORD
ARG JENASVNREVISION

WORKDIR /opt/STILT_svn
RUN svn --username $JENASVNUSER --password $JENASVNPASSWORD --non-interactive checkout --revision $JENASVNREVISION https://projects.bgc-jena.mpg.de/STILT/svn/trunk

WORKDIR /opt/STILT_modelling/
RUN cp -R /opt/STILT_svn/trunk/stiltR .
COPY setup.sh .
RUN chmod +x setup.sh && ./setup.sh && rm setup.sh

RUN echo $JENASVNREVISION && touch ./version_$JENASVNREVISION

WORKDIR /opt/STILT_svn/trunk/merged_stilt_hysplit
COPY Makefile .
RUN make
RUN mv hymodelc /opt/STILT_modelling/

WORKDIR /opt/STILT_modelling/stiltR/shlib
COPY build.sh .
