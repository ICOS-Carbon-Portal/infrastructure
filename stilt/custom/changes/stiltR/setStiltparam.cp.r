#################################
# set parameters needed for STILT
#################################
#---------------------------------------------------------------------------------------------------
# $Id: setStiltparam.r,v 1.1 2010/03/01 17:18:05 trn Exp trn $
#---------------------------------------------------------------------------------------------------

cat("setStiltparam.r: starting...\n")

cpTF<-T  # T: specific settings for ICOS-CP
         # F: default version

### get link to metadata to add to results csv file
metadata <- readLines("./metadata_link.txt")
print(paste("Link to metadata for model version and input files:",metadata,sep=" "))

###### set directories ######
###### make sure they exist, at least the ones in the following first paragraph

### run-specific parameters and directories for ICOS-CP
stilt_year <- Sys.getenv(c("STILT_YEAR"),unset = NA)
run_id <- Sys.getenv(c("RUN_ID"),unset = NA)
path_id<-paste("./Output/",run_id,"/",sep="")

path<-paste(path_id,"RData/",sep="") 		#path where output gets saved,
                                                         # also input data (Receptor locations and times)
                                                         # and boundary mixing ratio objects are read from 'path'
pathResults<-paste(path_id,"Results/",sep="")
pathFP<-paste(path_id,"Footprints/",sep="")
pathBinFootprint<-paste(path_id,"Footprints/",sep="")
shlibpath <- "./stiltR/shlib/"   # R extensions
metpath <- "/opt/STILT_modelling/Input/Metdata/Europe2/"    # where met data are stored in ARL format
vegpath<-"./Input/VPRM/" 	#path to get to surface fluxes and vegetation grids at various resolutions; not needed for VPRM
rundir <- paste("./",run_id,"/STILT_Exe/",sep="")                               # specifies main directory where different directories are found to run hymodelc

### optional directories
evilswipath<-paste("./Input/VPRM/VPRM_input_STILT_EU2_",stilt_year,"/",sep="")    # VPRM only -- input path for EVI and LSWI files (can be netcdf)
vprmconstantspath="./Input/VPRM/VPRMconstants/"   # VPRM only -- input path for file with VPRM constants
vprmconstantsname="vprmConstants.optEU2007n"                                 # VPRM only -- name of file with VPRM constants
nldaspath="/project/p1229/Radiation/NLDAS/"                             # VPRM only -- input path for NLDAS temperature and radiation


###### basic parameters ######
nhrs <- -10*24          # for how many hours to run (time-backward runs negative).
nparstilt <- 100        # how many particles per receptor? 100 of for receptor oriented modeling with dynamic grid resolution is ok
veght <- 0.5            # surface layer (for fluxes); if less than 1 then as fraction of mixed layer height; 0.5 is a good value.
convect <- T            # T for convection (RAMS winds: grell convection scheme, EDAS and FNL: simple redistribution within vertical range with CAPE>0)
stepsize <- 0           # Enforces Courant criterion. When >0: maximum horizontal distances travelled by a particle in a single timestep, in km.
                        # For dynamic resolution, choose value 0. First 12 hrs: 20 km; then 60 km
partperhymodelc <- 1    # use > 1 for grouping multiple receptors into each hymodelc run (subject to MaxHymodelDtmin)
MaxHymodelcDtmin <- 1*60 # max. discrepancy in receptor start times per hymodelc run

use.multi <- TRUE       # use multi-met version of hymodelc.  For this, define setup namelist parameters in the following:
hymodelc.exe <- "/opt/STILT_modelling/hymodelc"  # path to hymodelc executable (relative to rundir/Copy<n>). Use NULL
                        # to use the Trajecmulti default of "hymodelc", use "./hymodelc" if hymodelc is not in path
                        # and a local copy or link has been placed in the Copy<n> directory
setup.list <- list(     #see Trajecmulti for other choices and default values
		   VEGHT=0.5,            # surface layer (for fluxes); if less than 1 then as fraction of mixed layer height; 0.5 is a good value.
		   ICONVECT=1*convect,           # 0 for no convective redistribution, 1 for convection (RAMS winds: grell convection scheme, 
					 # EDAS and FNL: simple redistribution within vertical range with CAPE>0, ECMWF Tiedke type mass fluxes)
		   RANDOM=1,             #flag (1-yes) for using a random number generator that generates
                                         # diff random number sequence each time model is run
		   OUTDT=0.0,            #interval [min] that will determine how often particle data
         				 # are written out to PARTICLE.DAT; if outdt=0.0, then data at EVERY timestep is written out
		   KMIX0=-1              #mixing depth (abs(kmix0) is used as the minimum mixing depth,
        				 # negative values are used to force mixing heights coincident with model levels)
					 #default is 250 m!!!
		   )

                        # transport error due to wind error or mixing height error included as stochastic prozess?
                        # then need parameters for covariance matrices; otherwise set parameters to NULL
siguverr=NULL           # stddev of magnitude in horizontal wind errors [m/s]
TLuverr=NULL            # correlation timescale [min]
horcoruverr=NULL        # horizontal correlation lengthscale of horizontal winds [km]
zcoruverr=NULL          # vertical correlation lengthscale of horizontal winds [km]
sigzierr=NULL           # stddev of magnitude in mixed layer height errors [%]
TLzierr=NULL            # correlation timescale [min]
horcorzierr=NULL        # horizontal correlation lengthscale of mixed layer height errors [km]
ziscale=NULL            # scaling factor(s) for PBL height; NULL for default; -1 to use model pbl heights

metsource<-c("ECmetF")   # Source of Meteorological data, for analysis runs (not forecasts)
         #metsource      generating model                      dt    dx [km]      file duration  filename example
         #"edas"         Eta Data Assimilation System, NCEP    3h    80           0.5m           edas.subgrd.apr00.001
         #"edas40"       NAM (Eta) Data Assimilation System    3h    40           0.5m           edas.apr04.002
         #"fnl"          Global Data Assim, Syst. (GDAS) NCEP  6h    180          0.5m           fnl.nh.apr00.001
         #"fnl.nh"        - same (default is nh)               6h    180          0.5m           fnl.nh.apr00.001
         #"fnl.sh"        - southern hem.                      6h    180          0.5m           fnl.sh.apr00.001
         #"brams"        Brazilian implementation of RAMS      ~0.3h 40           1d             brams_12_15_2003_1.bin
         #"ecmw"         ECMWF                                 3h    35 (->2/06)  1d             ecmw.050511.arl
         #                                                           25 (2/06->)  1m
         #"ECmetF"       ECMWF, patched short term forecasts   3h    35 (->2/06)  72 - 144 h     ECmetF.05070100.arl
         #                                                           25 (2/06->)
         #"alad"         Aladin meso. forecasts (MeteoFrance)  3h    8            72h            aladinF.07042100.arl
         #"wrf"          Weather Research & Forecasting        0.3h  2-50         ?h             d01.20051223.arl
         #"d01", "do2",          WRF nested domains            0.3h  2-50         ?h             d01.20051223.arl



###### define receptors ######

###### Carbon Portal specific settings #######
station <- Sys.getenv(c("STILT_NAME"),unset = NA)
path<-paste(path,station,"/",sep="")
pathFP<-paste(pathFP,station,"/",sep="")
pathResults<-paste(pathResults,station,"/",sep="")
cat(format(Sys.time(), "%FT%T"),"INFO setStiltparam.r: station = ",station,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG Particle location files should be in ",path,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG Footprints will be in ",pathFP,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG Results will be in ",pathResults,"\n")
remove.Resultfile<-T     # T: remove stiltresult object and csv-file
                         # F: do not overwrite stitlresult object and csv-file, plot results only
modelwind<-T
Timesname<-paste(".",station,".",stilt_year,".request",sep="") #name of object containing frac. julian, lat, lon, agl (m) as receptor information;
				#this object needs to be saved (use assignr) in directory 'path' (see above)
				#can be created with create_times.r
                                #note that column names must be "fjul","lat","lon","agl"
###### end CP specific settings ######

Times.startrow=0        # for short test run; "Times.startrow" = row of Timesname object to start with; set to 0 for full run
Times.endrow=3; if (Times.startrow == 0) Times.endrow <- 0   # for short test run; "Times.endrow"= row of Timesname object to end with

#####################################
####### PARTICLE LOCATIONS ##########
###### control parameters for what STILT should do: Particle locations, mixing ratios or footprints ######
varstrajec<-c("time","index","lat","lon","agl","grdht","foot","temp0","swrad","zi","dens","dmass",
              "totrain","convrain","zconv","sigmaw","TL","pres")
			#specifies output variables from Trajec(); these will be output along the trajectory.
			# can be any subset of:
			#c("time","sigmaw","TL","lon","lat","agl","grdht","index","cldidx","temp0",
			#  "sampt","foot","shtf","lhtf","tcld","dmass","dens","rhf","solw","lcld",
			#  "zloc","swrad","wbar","zi","totrain","convrain","zconv","pres")
#      Detailed meaning:
#      FORTRAN ->   R
#     'time'   -> 'time'    !time since start of simulation
#     'sigw'   -> 'sigmaw'  !standard deviation of vertical velocity [m/s]
#     'tlgr'   -> 'TL'      !Lagrangian decorrelation timescale [s]
#     'long'   -> 'lon'     !particle longitude position [degrees]
#     'lati'   -> 'lat'     !particle latitude position [degrees]
#     'zagl'   -> 'agl'     !particle vertical position [m above-ground-level]
#     'zsfc'   -> 'grdht'   !terrain height [m]
#     'indx'   -> 'index'   !particle index
#     'icdx'   -> 'cldidx'  !cloud index (1 = updraft, 2=environment, 3=downdraft)
#     'temp'   -> 'temp0'   !air temperature at lowest model layer [K]
#     'temz'   -> 'temp'    !air temperature at particle location [K]
#     'pres'   -> 'pres'    !air pressure at particle location [mbar]
#     'samt'   -> 'sampt'   !amount of time that particle spends below 'VEGHT' [min]
#     'foot'   -> 'foot'    !sensitivity of mixing ratio to surface fluxes [ppm/(micro-moles/m2/s)]
#     'shtf'   -> 'shtf'    !sensible heat flux [W/m2]
#     'whtf'   -> 'lhtf'    !latent heat flux [W/m2]
#     'tcld'   -> 'tlcd'    !total cloud cover [%]
#     'dmas'   -> 'dmass'   !particle weight--changes due to mass violation [init value = 1.0]
#     'dens'   -> 'dens'    !air density [kg/m3]
#     'rhfr'   -> 'rhf'     !relative humidity fraction [0~1.0]
#     'sphu'   -> 'sphu'    !specific humidity [g/g]
#     'solw'   -> 'solw'    !soil moisture [units ???]
#     'lcld'   -> 'lcld'    !low cloud cover [%]
#     'zloc'   -> 'zloc'    !limit of convection heights [m]
#     'dswf'   -> 'swrad'   !downward shortwave radiation [W/m2]
#     'wout'   -> 'wbar'    !vertical mean wind [m/s]
#     'mlht'   -> 'zi'      !mixed-layer height [m]
#     'rain'   -> 'totrain' !total rain fall rate [m/min]
#     'crai'   -> 'convrain'!convective rain fall rate [m/min]
#     'zcfx'   -> 'zconv')  !vertical displacement due to
#                           !convective flux (deep or shallow,
#                           !up or downdraft) along trajectory [m]

overwrite=F             # T: rerun hymodelc, even if particle location object for same starting location and time is found;
                        # F: re-use previously calculated particle location object
remove.Trajfile=F       # T: remove trajectory files after VPRM (to prevent accumulation of large files) (default: F)
create.X0=F             # T: Save zero-time values in separate initial trajectory file (default: F)


################################
####### MIXING RATIOS ##########
fluxTF<-T			#mapping to emission fluxes and diagnostic biosphere CO2 fluxes (call of cunction Trajecvprm)


emisscatTF<-T #add tracers for different edgar categories/fuel types
if(emisscatTF){
  edgar.path<-"./Input/EDGARv4.3/STILT_EU2/"
  edgar.path.write<-"./stiltR/EDGAR/"
#################################################
#### edit "set.edgar.r" for changing tracers when using different edgar categories/fuel types (i.e. "emisscatTF<-T")
  source(paste(sourcepath,"set.edgar.r",sep=""))#### edit "set.edgar.r" for changing tracers when using different edgar categories/fuel types
} else {

  tracer.names.all<-tolower(c("co2","co","ch4","n2o","h2","cofire"))	#vector of names for which mixing ratios are calculated; any subset of c("co","co2","ch4")
  tracer.info<-rbind(
  #################################################
  #### edit following part for each tracer ########
  #    "co2",    "co",     "ch4",   "n2o",   "h2",   "cofire"
  c(       T,       F,         F,        F,        F,        F), #want tracer? H2 is not ready at the moment, needs proper implementation in Trajecvprm()
  c(       T,       F,         F,        F,        F,        F), #surface fluxes in netCDF format (T) or as R objects (F)? (In case of CO2: same format for fossil fluxes
                                             #and biospheric fields (veg cover, modis indices)
c("./Input/EDGARv4.1_BP2012/STILT_EU2/EDGAR_4.1_0.1x0.1.CO2.2011.nc",                                           #full name for emission file (CO2)
             "/Net/Groups/BSY/tools/STILT/fluxes_input/IER_Stuttgart/Europe/CO.2000.nc",                        #full name for emission file (CO)
                      "/Net/Groups/BSY/tools/STILT/fluxes_input/IER_Stuttgart/Europe/CH4.2000.nc",              #full name for emission file (CH4)
                                 "/Net/Groups/BSY/tools/STILT/fluxes_input/IER_Stuttgart/Europe/N2O.2000.nc",   #full name for emission file (N2O)
                                          "/Net/Groups/BSY/tools/STILT/fluxes_input/IER_Stuttgart/Europe/N2O.2000.nc",  #full name for emission file (H2)
                                                      "/Net/Groups/BSY/tools/people/cgerbig/RData/ROAM/Fluxes/BARCAfires/ncdf/CO.barcafire2009.nc"),  #full name for emission file (cofire)
  #    "co2",    "co",     "ch4",   "n2o",   "h2",   "cofire"
  c(   "TM3", "climat",    "TM3",       "",       "",       ""),                                                    #inikind, possible values: "climat" (Gerbig et al. (2003)),
                                                                                                          #"CT" (CarbonTracker), "TM3", "LMDZ", "MACCfc", "" (zero boundary)

  c("./Input/INI_BDY/TM3/CO2/mu1.0_070_mix_Y_fg.nc",                                     #(not for "climat") full name for initial & boundary cond. file (CO2)
             "",                                                                                          #full name for initial & boundary cond. file (CO)
                      "/Net/Groups/BSY/tools/STILT/fluxes_input/TM3_CH4/mmix_ch4_s1.b",                         #full name for initial & boundary cond. file (CH4)
                                 "",                                                                      #full name for initial & boundary cond. file (N2O)
                                           "",                                                            #full name for initial & boundary cond. file (H2)
                                                     ""))                                                 #full name for initial & boundary cond. file (COfire)
                                                                                                          #in these file names "YYYY" gets automatically
                                                                                                          #substituted by the required year
} #end of "if(emisscatTF){ } else {"

####### don't modify ##########
dimnames(tracer.info)<-list(c("wanted","ncdfTF","emissfile","inikind","inifile"),tracer.names.all)
fluxtracers<-tracer.names.all[as.logical(tracer.info["wanted",])]

ncdfTF<-as.logical(tracer.info["ncdfTF",]); names(ncdfTF)<-tracer.names.all
emissfile<-tracer.info["emissfile",]; names(emissfile)<-tracer.names.all
inikind<-tracer.info["inikind",]; names(inikind)<-tracer.names.all
inifile<-tracer.info["inifile",]; names(inifile)<-tracer.names.all
####### END don't modify ##########

aggregation <- 1                # degrade resolution (for aggregation error): 0: use only highest resolution at 20 km;
        #  1-32: dynamic resolution.
        #  1: starts with highest resolution of 20 km, then degrades resolution as footprint size increases
        #  2-32: starts with coarser resolution (see table below)
        # aggregation:  1     2     4      8       16       32
        # coarser in x: 1 1 2 2 2 4 4 4 8  8  8 16 16 16 32 32 # factors by which grids have been made coarser
        # coarser in y: 1 2 1 2 4 2 4 8 4  8 16  8 16 32 16 32 # e.g., '4' means grid is 4 times coarser
if (stepsize == 0 & aggregation == 0) {aggregation <- 1; print("override: aggregation changed to dynamic for stepsize=0!")}


#*******Choice of biosphere -- either GSB (Greatly simplified biosphere) or VPRM (Vegetation photosynthesis and respiration model
# The GSB is appropriate where a simple surface flux model is needed; VPRM is appropriate where most accurate surface fluxes are desired
# Note: Both are computationally efficient; VPRM takes significant preprocessing time and file space.
fluxmod <- "VPRM"                # Which surface flux model to use: "GSB" or "VPRM" or "" to not use biosphereic CO2 fluxes
detailsTF <- FALSE              # detailsTF' if TRUE, for each particle the flux contribution is saved in a big object
                                # WARNING: setting detailsTF=TRUE may result in large files being created and stored

# GSB options
linveg <- FALSE                 # if TRUE, CO2 fluxes are represented as linear functions of temperature and radiation (otherwise GEE is non linear)

# VPRM options
usenldasrad <- FALSE            # If TRUE, nldas radiation is read from a library and used to drive the model; If FALSE output from assimilated is used
usenldastemp <- FALSE           # If TRUE, nldas temperature is read from a library and used to drive the model; If FALSE output from assimilated is used
pre2004 <- FALSE                # For conversion of shortwave radiation to PAR; the assimilated models (specifically edas) changed at the beginnning of 2004
        # this specifies which conversion factor to use.
keepevimaps <- FALSE            # this assigns evi and lswi maps to the global environment -- saving significant I/O processing time
        #**BE CAREFUL** when using this, as it will put a number of LARGE objects in your database. If dynamic memory
        # allocation problems are anticipated, this feature should NOT be used!!!
                                #this variable does not matter when using netCDF format


###########################################
####### FOOTPRINTS AND INFLUENCE ##########
# Output will be a 3 D array of Influence (or Surface Influence/Footprints)
# these objects are given names that reflect starting location and time
# e.g. "foot2002x08x01x00x42.54Nx072.17Wx00030"
# NOTE: Storage requirement for one footprint timestep is about 1 Mb,
# so for time resolved footprints over ~weeks this can easily reach
# 200 Mb per receptor
footprintTF <- T        # calculate footprint (surface influence) or "volume" influence
#foottimes <- c(0,10,20) # vector of times (backtimes) in hours between which footprint is computed
foottimes <- c(0,-nhrs) # vector of times (backtimes) in hours between which footprint is computed
ftintr  <- 0              # interval for footprint integration, if ftintr==0, use foottimes as defined above
if(ftintr==1){            # hourly intervals for coupling to fluxes are independent of starting time and can be precalculated
                          # for longer intervals need to ensure that beginning and end for each interval matches flux field integration,
                          # which is usually on UTC
  nfoottimes <- -nhrs/ftintr+1               #number of footprints computed
  foottimes<-rep(c(0),nfoottimes)            #vector of times (backtimes) in hours between which footprint is computed
  nftpix<-rep(c(0),nfoottimes)               #vector of numbers of pixels in each footprint
  for(ft in 1:nfoottimes){
  foottimes[ft]<-0+(ft-1)*ftintr
}}

zbot <- 0               # lower vertical bound for influence projection, in meters agl
ztop <- 0               # upper vertical bound for influence projection, in meters agl
                        # if ztop set to zero, surface influence will be calculated
footplotTF <- F         # plotting of footprints; will be plotted to png file in directory path + "/Footprints"
numpix.x<- 400                  #number of pixels in x directions in grid (188 or 47)
numpix.y<- 480                  #number of pixels in y directions in grid (108 or 27)
lon.res <- 1/8                  #resolution in degrees longitude
lat.res <- 1/12                  #resolution in degrees latitude
lon.ll  <- -15                 #lower left corner of grid
lat.ll  <-  33                 #lower left corner of grid

landcov<-"SYNMAP.VPRM8"         #which landcover to use?
				#	IGBP -- Original IGBP, from Christoph
				#	GLCC -- Original VPRM, based on updated IGBP (GLC2.0)
				#	DVN -- The updated Devan system
				#       'SYNMAP' Martin Jung synmap product
				#       'SYNMAP.VPRM8' 8 VPRM classes based on synmap product

writeBinary =F           # write binary (TRUE) or ASCII (FALSE) files?

#####################################################################
####### nested grid, for running VPRM in inner domain only ##########
#default: fullgrid
subill<-lon.ll			# lower left lon			
subjll<-lat.ll			# lower left lat
subiur<-lon.ll+numpix.x*lon.res	# upper right lon
subjur<-lat.ll+numpix.y*lat.res	# upper right lat

#comment out or in and modify lines below if nested region is desired; 
#veg. cover from get.modis.netcdf() is set to zero in regions outside of nest
#causing zero influence
#subill<--2			# lower left lon
#subjll<-43			# lower left lat
#subiur<-3			# upper right lon
#subjur<-46			# upper right lat

##transform to indices #don't modify below
subill <- floor(1/lon.res*(subill-lon.ll)+1)
subjll <- floor(1/lat.res*(subjll-lat.ll)+1)
subiur <- floor(1/lon.res*(subiur-lon.ll))
subjur <- floor(1/lat.res*(subjur-lat.ll))

#check grid consistency, only dimensions
if(fluxmod=="VPRM"&fluxTF){
  checkdim<-get.vprm.dim(evilswipath)
  if(numpix.x!=checkdim["nx"]|numpix.y!=checkdim["ny"])print("setStiltparam.r: grid dimensions don't match VPRM field dimensions")
  #also set number of vegetation classes for check in Trajecvprm
  n.vegclass<-checkdim["nv"]
}

###########################################
### CO CONTRIBUTION FROM BIOMASS BURNING ##
# Set the following parameters if you are modelling CO and would like to include influence from forest fires.
# The output will be saved in its own file in the path directory.  At present, model only works for CO in 2004.
biomassburnTF <- F                              # Should the biomassburning model for CO be run?

burnpath <- "/home/smiller/biomass_burning/"    # This is the path to the biomass burning files (These files should
             # be modified as in /homes/smiller/biomassburning/modified_fireemis_script.txt).

############ set up boundary fields and OH #######################
# required only 1st time to set up grids
######## OH fields (climatological values, 12 months, 16 different latitudes, parameterized pressure dependence ########
# from a fit to data from the paper
# Taraborrelli, D., Lawrence, M., Crowley, J. et al. Hydroxyl radical buffered by isoprene oxidation over tropical forests. Nature Geosci 5, 190\u2013193 (2012). https://doi.org/10.1038/ngeo1405
if (fluxTF) {
  oh <- read.csv(paste(sourcepath, "OH_5deg_polynomial.csv", sep=""));oh<-oh[,-1]
  colnames(oh)[1:4]<-c("month","lat","latS","latN");oh[,5:10]<-oh[,5:10]*1E5#now in molec./cm^3
  ohn<-oh
  for(i in 1:length(unique(oh[,"lat"]))){#get proper boundaries between latitude bands
    lati<-unique(oh[,"lat"])[i]
    ids<-which(oh[,"lat"]==lati)
    if(i==1){ohn[ids,"latS"]<- -90} else {ohn[ids,"latS"]<-(oh[ids,"latS"]+oh[ids-1,"latN"])/2}
    if(i==length(unique(oh[,"lat"]))){ohn[ids,"latN"]<- 90} else {ohn[ids,"latN"]<-(oh[ids,"latN"]+oh[ids+1,"latS"])/2}
  }
  oh<-ohn
}

# only when necessary (new tracer or new time span)
# get boundary conditions
if(any(inikind[fluxtracers]=="climat")){
  if (fluxTF & !existsr(paste(tolower(fluxtracers[1]), ".ini", sep=""), path)) {
    print(paste("setStiltparam.r: no ", fluxtracers[1], " boundary fields found!", sep=""))
               print("need to use read.bg()")
#        print("only valid for CO and CO2 from 1/1/99 to 12/31/02!!")
    read.bg(spec=c("CO2", "CO"), datename="1_1_03_12_31_04", pathin="/group/wofsy/stilt/Boundary/", pathout=path)
  }
}
# get CO2 flux parameters
if (fluxTF) {library(foreign); data.restore(paste(sourcepath, "dlambda.veg.dmp", sep=""), print=F)}
if (fluxTF & linveg) {dlambda.simp.veg <- getr("dlambda.simp.veg", path="/Net/Groups/BSY/BSY_3/cgerbig/Rsource/polarR/")}
# object dlambda.veg contains parameters of simple light and temperature fit to Fluxnet data
# NEE=drdt * T  + a3 * swrad / (a4 + swrad)
# dlambdaGEE and dlambdaR are relative uncertainties in 3 day aggregated gross fluxes (GEE and R)
#     vgroup        a3        a4       drdt dlambdaGEE dlambdaR
#[1, ]      1 -25.19497  566.9109 0.18198077  1.4316519 2.260087
#[2, ]      2  -1.17163   95.7913 0.05482351  3.0875475 7.879271
#[3, ]      3 -64.67396 1466.6771 0.18856880  0.4396042 1.188944

######## check on surface flux grids and vegetation classification after IGBP ########
if (fluxTF&!ncdfTF["co2"]&!emisscatTF&any(fluxtracers=="co2")) {
  if (landcov == "IGBP") {
    veghead <- "veg."
  } else if (landcov == "GLCC") {
    veghead <- "glcc."
  } else if (landcov == "DVN") {
    veghead <- "devanveg."
  } else if (landcov == "SYNMAP") {
    veghead <- "synmap."
  } else if (landcov == "SYNMAP.VPRM8") {
    veghead <- "synvprm8."
  } else {
    stop("setStiltparam: Improperly specified Landcover format; Exiting now!")
    veghead <- "veg."
  }

  if (fluxTF & !existsr(paste(veghead, "1.001", sep=""), vegpath)) {
  stop("setStiltparam: NO surface flux grids found")
  # source(paste(sourcepath, "gen_veg_mat.r", sep=""))
  }
} # if fluxTF

# Read in the required parameters for the CO biomassburning script.
if (biomassburnTF) {
  biomassburning <- read.table(file=paste(burnpath, "modified_FireEmis_2004.txt", sep=""), header=T, row.names=NULL)
  source(paste(sourcepath, "trajecbiomassburn2.r", sep="")) }
