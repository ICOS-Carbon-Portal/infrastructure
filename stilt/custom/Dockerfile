FROM stiltbase

COPY ./changes/cp_tools/* /opt/STILT_modelling/
COPY ./changes/stiltR/* /opt/STILT_modelling/stiltR/
COPY ./changes/stiltR/setStiltparam.cp.r /opt/STILT_modelling/setStiltparam.r
COPY ./changes/stiltR/shlib/* /opt/STILT_modelling/stiltR/shlib/

WORKDIR /opt/STILT_modelling/stiltR/shlib/
RUN ./build.sh
WORKDIR /opt/STILT_modelling
