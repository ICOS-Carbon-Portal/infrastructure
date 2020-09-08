# change to scipy notebook 
# remove anaconda

FROM jupyter/scipy-notebook@sha256:e89b7047155fdf359152cf3fa34140e4ce8158d96eabb15fe42cc8cf587b6635

# Install Python 3 packages

RUN conda install -y jupyterlab
RUN conda install -y basemap-data-hires
RUN conda install -y bokeh cartopy
RUN conda install -y geoviews holoviews
RUN conda install -y panel datashader hvplot param
RUN conda install -y ipywidgets xlrd
RUN conda install -y cdo python-cdo
RUN conda install -y geopandas mpld3 pscript
RUN conda install -y netcdf4
RUN conda install -y tqdm ipyleaflet netcdf-fortran
RUN conda install -y folium
RUN conda install -y pytables hdf5
RUN conda install -y basemap bottleneck pandas
RUN conda install -y sparqlwrapper xarray
RUN conda install -y shapely

RUN conda clean --all -f -y

# PIP libraries 
RUN pip install icoscp

######

RUN apt update -y && apt install -y iproute2 iputils-ping
RUN useradd --create-home jovyan

# These were taken from the jupyter/base-notebook image
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/

WORKDIR /home/jovyan

ADD education ./education
ADD icos_jupyter_notebooks ./icos_jupyter_notebooks
ADD project_jupyter_notebooks ./project_jupyter_notebooks
ADD introduction ./introduction

RUN chown -R jovyan: /home/jovyan

# CMD ["jupyterhub-singleuser", "--debug", "--ip=0.0.0.0"]
CMD ["start-notebook.sh"]
USER jovyan

COPY execute-in-environment.sh /
ENTRYPOINT ["/execute-in-environment.sh"]
