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

RUN wget https://packagemanager.rstudio.com/cran/latest/src/contrib/dotCall64_1.0-2.tar.gz
RUN R CMD INSTALL dotCall64_1.0-2.tar.gz

RUN wget https://packagemanager.rstudio.com/cran/latest/src/contrib/spam_2.9-1.tar.gz
RUN R CMD INSTALL spam_2.9-1.tar.gz

RUN wget https://packagemanager.rstudio.com/cran/latest/src/contrib/fields_15.2.tar.gz
RUN R CMD INSTALL fields_15.2.tar.gz

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
