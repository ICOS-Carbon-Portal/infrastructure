#***************************************************************************************************
# Function that loops over all starting times
#***************************************************************************************************

Trajecmod <- function(partarg=NULL, totpartarg=NULL, nodeoffset=NULL, stiltparamfile=NA) {

#---------------------------------------------------------------------------------------------------
# Calls 'Trajec' for each starting time
# arguments assigned from call to setStiltparam.r
#
# $Id: Trajecmod.r,v 1.32 2013/12/10 17:58:31 trn Exp $
#---------------------------------------------------------------------------------------------------


# need to assign parameters; also save parameter setting in archive file with date in name
if(is.na(stiltparamfile))source("setStiltparam.r") else {source(stiltparamfile);print(paste("Trajecmod using",stiltparam))}
savename <- gsub(" ", ".", date())
savename <- substring(savename,4)
runs.done.dir <- NULL

if (cpTF){                  # ICOS-CP specific settings
if (file.exists(paste('./',run_id,'/Runs.done',sep=''))) runs.done.dir <- paste('./',run_id,'/Runs.done/',sep='')
} else {
if (file.exists('./Runs.done')) runs.done.dir <- './Runs.done/'
if (is.null(runs.done.dir) && file.exists(paste(sourcepath,'Runs.done',sep='')))
  runs.done.dir <- paste(sourcepath,'/Runs.done/',sep='')
if (is.null(runs.done.dir) &&
    substring(path, nchar(path)-nchar("Runs.done"), nchar(path)) == "Runs.done/")
  runs.done.dir <- sourcepath
}
if (!is.null(runs.done.dir)) {
   file.copy("setStiltparam.r",
             paste(runs.done.dir, "setStiltparam", savename, ".r", sep=""),
             overwrite=T)
   cat("Saving copy of setStiltparam.r in ",
       paste(runs.done.dir, "setStiltparam", savename, ".r", sep=""),
       "\n",sep="")
} else {
   cat("No Runs.done directory; parameter information not saved\n")
}
if (!exists("doubletimeTF"))doubletimeTF<-FALSE #flag for near-field interpolation of trajectory output; if not set in setStiltparam.r, set here


totpart <- 1
if (!is.null(totpartarg)) {
  cat('resetting totpart=', totpart, ' to totpartarg=', totpartarg, '\n', sep='')
  totpart <- totpartarg
}
part <- 1
if (!is.null(partarg)) {
  cat('Using totpart=', totpart, ' resetting part=', part, ' to partarg=', partarg, '\n', sep='')
  part <- partarg
}
if (!is.null(nodeoffset)) {
  nummodel <- part+nodeoffset
  cat('Using nodeoffset= ', nodeoffset, ' ,results in nummmodel= ', nummodel, '\n', sep='')
} else {
  nummodel <- part
}



# get Starting info
if (cpTF) {
  if (!exists("path_timesname")) {path_timesname<-pathResults} 
} else {
  if (!exists("path_timesname")) {path_timesname<-path} #new tk
}
if (!existsr(Timesname, path_timesname)) stop(paste("cannot find object ", Timesname, " in directory ", path_timesname, sep=""))
StartInfo <- getr(paste(Timesname, sep=""), path_timesname) # object containing fractional julian day, lat, lon, agl for starting position and time

# SELECTION OF A FEW Receptors for testing!
if (Times.startrow > 0) StartInfo <- StartInfo[Times.startrow:Times.endrow,, drop=FALSE] # can be just one (Times.startrow=Times.endrow)
nreceptors <- dim(StartInfo)[1]
# divide job into "totpart" parts to speed up
if (dim(StartInfo)[1] < totpart) {
  cat ('Warning: resetting totpart=', totpart, ' to dim(StartInfo)[1]=', dim(StartInfo)[1], '\n', sep='')
  totpart <- dim(StartInfo)[1]
}
if (part > totpart) {
  stop.message <- paste('Specified part=', part, ' > totpart=', totpart, ', stopping\n')
  cat(stop.message)
  stop(stop.message)
}

if(totpart>1){
  n.perpart<-rep(dim(StartInfo)[1]%/%totpart,totpart)
  if((dim(StartInfo)[1]%%totpart)>0)n.perpart[1:(dim(StartInfo)[1]%%totpart)]<-n.perpart[1:(dim(StartInfo)[1]%%totpart)]+1
  start.rows=c(1,cumsum(n.perpart)+1)
  StartInfo <- StartInfo[start.rows[part]:(start.rows[part+1]-1),, drop=FALSE]
}
dimnames(StartInfo)[[2]] <- toupper(dimnames(StartInfo)[[2]])

if (biomassburnTF) {
   biomassburnoutmat <- matrix(nrow=dim(StartInfo)[[1]], ncol=2)
   dimnames(biomassburnoutmat) <- list(NULL, c("ident", "CO"))
}

if (cpTF){
  if (file.access(pathResults,0)!=0) {
       system(paste("mkdir ",pathResults,sep=""))
  }
  path_stiltresult <- pathResults   # to keep in sync with default path name 
  l.remove.Resultfile <- FALSE
  if (exists('remove.Resultfile')) l.remove.Resultfile <- remove.Resultfile
  lat <- StartInfo[1, "LAT"]; lon <- StartInfo[1, "LON"]; agl <- StartInfo[1, "AGL"]
  identname <- pos2id(StartInfo[1,1], lat, lon, agl)
  stiltresultname <- paste("stiltresult",stilt_year,substr(identname,14,34),"_",sep="")
  cat(format(Sys.time(), "%FT%T"),"INFO new result filename: ",stiltresultname,"\n")
  # OVERWRITE WARNING
  if(existsr(paste(stiltresultname,part,sep=""),path=pathResults)) {
     if(l.remove.Resultfile){
        cat(format(Sys.time(), "%FT%T"),"DEBUG You are attempting to overwrite an existing stiltresult object\n")
        unix(paste("rm -f ",paste(pathResults,".RData",stiltresultname,part,sep=""),sep=""))
        unix(paste("rm -f ",paste(pathResults,stiltresultname,part,".csv",sep=""),sep=""))
        cat(format(Sys.time(), "%FT%T"),"DEBUG Notice: New stiltresult object will be written \n")
     }else{ 
        cat(format(Sys.time(), "%FT%T"),"DEBUG You are not computing new timeseries you are using an existing stiltresult object\n")
        cat(format(Sys.time(), "%FT%T"),"DEBUG Notice: If you have changed parameters and Trajecmod fails, first try to move or remove the existing stiltresult object\n")
        fluxTF<-F    # no new time series are computed
     }
  }else{
     cat(format(Sys.time(), "%FT%T"),"DEBUG Notice: New stiltresult object will be written \n")
  }
} else {
  # OVERWRITE WARNING
  if (!exists("path_stiltresult")) {path_stiltresult<-path} #new tk
  stiltresultname <- "stiltresult"
  if(existsr(paste(stiltresultname,part,sep=""),path=path_stiltresult)) {
     warning("You are attempting to overwrite an existing stiltresult object")
     warning("Notice: If you have changed parameters and Trajecmod fails, first try to move or remove the existing stiltresult object")
  }
  if (!exists("path_foot")) {path_foot<-path} 
}

nrows <- length(StartInfo[,1]) # 1 row for each trajectory
rownum <- 1
firsttraj <- T
firstflux <- T
l.remove.Trajfile <- FALSE
if (exists('remove.Trajfile')) l.remove.Trajfile <- remove.Trajfile
l.ziscale <- NULL
if (exists('ziscale')) l.ziscale <- ziscale
l.zsg.name <- NULL
if (exists('zsg.name')) l.zsg.name <- zsg.name
l.create.X0 <- FALSE
if (exists('create.X0')) l.create.X0 <- create.X0
l.use.multi <- TRUE
if (exists('use.multi')) l.use.multi <- use.multi
l.hymodelc.exe <- NULL
if (exists('hymodelc.exe')) l.hymodelc.exe <- hymodelc.exe
l.write.r <- TRUE
if (exists('write.r')) l.write.r <- write.r
l.write.nc <- FALSE
if (exists('write.nc')) l.write.nc <- write.nc
# set options for pos2id encoding (defaults are for old-style)
l.encode.minutes <- FALSE
if (exists('encode.minutes')) l.encode.minutes <- encode.minutes
l.digits.latlon <- 2
if (exists('digits.latlon')) l.digits.latlon <- digits.latlon
l.digits.agl <- 0
if (exists('digits.agl')) l.digits.agl <- digits.agl
# newer trajecmulti options:
l.MaxHymodelcDtmin <- 18*60 # no more than 18 hours discrepancy in receptor start times per hymodelc run
if (exists('MaxHymodelcDtmin')) l.MaxHymodelcDtmin <- MaxHymodelcDtmin
l.partperhymodelc <- 1
l.use.minutes <- FALSE
l.dxyp <- 0.
l.dzp <- 0.
if (l.use.multi) {
  l.setup.list <- list()
  if (exists('setup.list')) l.setup.list <- setup.list
  if (exists('use.minutes')) l.use.minutes <- use.minutes
  if (exists('partperhymodelc')) l.partperhymodelc <- partperhymodelc
  if (exists('dxyp')) l.dxyp <- dxyp
  if (exists('dzp')) l.dzp <- dzp
}
# Clean out old hymodelc.out file from previous run, if any:
if (file.exists(paste(rundir,"Copy",nummodel,"/","hymodelc.out",sep="")))
  file.remove(paste(rundir,"Copy",nummodel,"/","hymodelc.out",sep=""))
j1 <- 1
while (j1 <= nrows) {
  j2 <- min(nrows,j1+l.partperhymodelc-1)
  if (j2-j1 > 0) {
    # Only lump together receptors that are within MaxHymodelcDtmin minutes of each other
    # and that have the same value of qhrs:
    timediffs <- abs(StartInfo[j1,1]-StartInfo[(j1+1):j2,1])*24*60
    largediffs <- timediffs > l.MaxHymodelcDtmin
    if ('QHRSRECEPTOR' %in% colnames(StartInfo))
      largediffs <- largediffs | (StartInfo[(j1+1):j2,'QHRSRECEPTOR'] !=
                                  StartInfo[j1,'QHRSRECEPTOR'])
    if (any(largediffs))
      j2 <- j1 + min((1:length(largediffs))[largediffs]) - 1
  }
      
  lat <- StartInfo[j1:j2, "LAT"]; lon <- StartInfo[j1:j2, "LON"]; agl <- StartInfo[j1:j2, "AGL"]
  identname <- pos2id(StartInfo[j1:j2,1], lat, lon, agl, encode.minutes=l.encode.minutes,
                      digits.latlon=l.digits.latlon,digits.agl=l.digits.agl)
  for (xident in identname) cat("Trajecmod(): ", xident, " running at ", date(), "\n", sep="")
  if ('NHRSRECEPTOR' %in% colnames(StartInfo)) {
    this.nhrs <- StartInfo[j1:j2,'NHRSRECEPTOR']   # use parameter as set in receptor list
  }else{
    this.nhrs <- rep(nhrs,j2-j1+1)  # use parameter as set in setStiltparam.r
  }
  if ('QHRSRECEPTOR' %in% colnames(StartInfo)) {
    qhrs <- StartInfo[j1:j2,'QHRSRECEPTOR']   # use parameter as set in receptor list
  }else{
    qhrs <- rep(1./3600.,j2-j1+1)  # use default: 1 sec (always < dt) for instantaneous receptors
  }
  if ('DXYPRECEPTOR' %in% colnames(StartInfo)) {
    this.dxyp <- StartInfo[j1:j2,'DXYPRECEPTOR']   # use parameter as set in receptor list
  }else{
    this.dxyp <- rep(l.dxyp,j2-j1+1)  # use parameter as set in setStiltparam.r
  }
  if ('DZPRECEPTOR' %in% colnames(StartInfo)) {
    this.dzp <- StartInfo[j1:j2,'DZPRECEPTOR']   # use parameter as set in receptor list
  }else{
    this.dzp <- rep(l.dzp,j2-j1+1)  # use parameter as set in setStiltparam.r
  }
  dat <- month.day.year(floor(StartInfo[j1:j2,1])) # from julian to mmddyy
  yr4 <- dat$year # 4 digit year
  yr <- yr4%%100 # 2 digit year (or 1 digit...)
  mon <- dat$month
  day <- dat$day
  hr.float <- (StartInfo[j1:j2,1]-floor(StartInfo[j1:j2,1]))*24
  hr <- round(hr.float)
  mn <- rep(0,j2-j1+1)
  if (l.use.minutes) {
    # NOTE: mn here is now the actual minutes of the receptor time:
    hr <- floor(hr.float)
    mn <- round(60.*(hr.float-hr))
  }
  if (l.use.multi) {
    info <- Trajecmulti(yr=yr, mon=mon, day=day, hr=hr, mn=mn, lat=lat, lon=lon, agl=agl,
                        outname=identname,nhrs=this.nhrs,emisshrs=qhrs,dxyp=this.dxyp,dzp=this.dzp,
                        numpar=nparstilt, doublefiles=T, metd=metsource, metlib=metpath,
                        conv=convect, overwrite=overwrite, outpath=path, varsout=varstrajec, rundir=rundir,
                        nummodel=nummodel, sourcepath=sourcepath, ziscale=l.ziscale, zsg.name=l.zsg.name,
                        create.X0=l.create.X0,setup.list=l.setup.list,hymodelc.exe=l.hymodelc.exe,
                        write.r=l.write.r,write.nc=l.write.nc,
                        siguverr=siguverr,TLuverr=TLuverr,zcoruverr=zcoruverr,horcoruverr=horcoruverr,
                        sigzierr=sigzierr,TLzierr=TLzierr,horcorzierr=horcorzierr)
  } else {
    info <- Trajec(yr=yr, mon=mon, day=day, hr=hr, lat=lat, lon=lon, agl=agl, nhrs=nhrs,
                   maxdist=stepsize, numpar=nparstilt, doublefiles=T, metd=metsource, metlib=metpath,
                   conv=convect, overwrite=overwrite, outpath=path, varsout=varstrajec, rundir=rundir,
                   nummodel=nummodel, sourcepath=sourcepath, ziscale=l.ziscale, zsg.name=l.zsg.name,
                   create.X0=l.create.X0,
                   siguverr=siguverr,TLuverr=TLuverr,zcoruverr=zcoruverr,horcoruverr=horcoruverr,
                   sigzierr=sigzierr,TLzierr=TLzierr,horcorzierr=horcorzierr)
  }

  if(cpTF){
    #=====================extracted from trajwind.r
    if(modelwind){
      print('modelwind')
      tdat<-getr(identname,path=path)# search .RData in outpath
      if(length(tdat)==0){ubar <- vbar <- wbar <- dir <- NA}
      if(length(tdat)==1){if(is.na(tdat))  ubar <- vbar <- wbar <- dir <- NA}
      if(length(tdat)>1) {
        sel<-abs(tdat[,"time"])==min(unique(abs(tdat[,"time"])))
        nmins<-abs(tdat[sel,"time"])
        delx<-1000*distance(x1=tdat[sel,"lon"],x2=lon,y1=lat,y2=lat)    #distance in [m]
        ubar<-mean(sign(tdat[sel,"lon"]-lon)*delx/(nmins*60))     #U-velocity [m/s]
        dely<-1000*distance(x1=lon,x2=lon,y1=tdat[sel,"lat"],y2=lat)    #distance in [m]
        vbar<-mean(sign(tdat[sel,"lat"]-lat)*dely/(nmins*60))     #V-velocity [m/s]
        delz<-abs(tdat[sel,"agl"]-agl)                                    #distance in [m]
        wbar<-mean(sign(tdat[sel,"agl"]-agl)*delz/(nmins*60))     #W-velocity [m/s]
        if (nhrs<0) {
          #if run backward in time then wind direction needs to be reversed 
          ubar <- -ubar
          vbar <- -vbar
          wbar <- -wbar
        }
        dir<-270.-atan2(vbar,ubar)*(180/(pi))
        if(dir>360) dir <- dir-360          
      }
    }
  #================end trajwind.r
  }
  if (is.null(dim(info))) {
    infonames <- names(info)
  } else {
    infonames <- dimnames(info)[[2]]
  }
  if (firsttraj) { # set up array for run info
    run.info <- matrix(NA, nrow=nrows, ncol=length(infonames))
    dimnames(run.info) <- list(NULL, infonames)
    firsttraj <- F
  } else {
    havenames <- dimnames(run.info)[[2]]
    for (nm in infonames) {
      ndx <- which(havenames == nm)[1] # check if there are new column names
      if (is.na(ndx)) { # new column name, need to add column
        run.info <- cbind(run.info, rep(NA, dim(run.info)[1]))
        dimnames(run.info)[[2]][dim(run.info)[2]] <- nm
      }
    }
  }
  run.info[j1:j2, infonames] <- info

  #########################################################################
  ###### TM3-STILT ################
  if(writeBinary == T){
    if (j2>j1) stop ('non-unity partperhymodelc not supported for writeBinary=TRUE; first calculate trajectories only')

    ####### variables for writing to binary files ######
    dlat   <-as.numeric(lat,digits=10)
    dlon   <-as.numeric(lon,digits=10)
    dagl   <-as.numeric(agl,digits=10)
    dlatres<-as.numeric(lat.res,digits=10)
    dlonres<-as.numeric(lon.res,digits=10)

    ####### construct filename for binary file #########
    cyr<-as.character(2000+yr)
    cmon<-as.character(mon)
    cday<-as.character(day)
    chr<-as.character(hr)
    x1<-""; x2<-""; x3<-""
    if(mon<10) x1<-paste(x1,"0",sep="")
    if(day<10) x2<-paste(x2,"0",sep="")
    if(hr<10)  x3<-paste(x3,"0",sep="")

    pathBinFootprintstation<-paste(pathBinFootprint,station,"/",sep="")
    if (file.access(pathBinFootprintstation,0)!=0) {
      system(paste("mkdir ",pathBinFootprintstation,sep=""))
    }

    filename<-paste(pathBinFootprintstation,station,"_",as.character(-nhrs),"h0",as.character(ftintr),
                    "h_",cyr,x1,cmon,x2,cday,x3,chr,"_",gridtag,cendian,".d",sep="")
# Jan's version with height in filename
#    filename<-paste(pathBinFootprintstation,station,"_",as.character(-nhrs),"h0",as.character(ftintr),
#                    "h_",cyr,x1,cmon,x2,cday,x3,chr,"_",sprintf("%5.5d",as.integer(agl)),"_",gridtag,cendian,".d",sep="")

    if (file.exists(filename)) {
      print(paste("Binary footprint file ",filename," already exists"))
      print(paste("not replaced !!"))
    }else{
      ident<-identname
      print(paste(path,".RData",ident,sep=""))
      if (file.exists(paste(path,".RData",ident,sep=""))) {

      #for longer than hourly intervals for footprints, first make sure to match time intervals of flux fields
      #assume those are e.g. 0-3, 3-6 etc. UTC, or 0-24 UTC 
      #NOTE: only for hourly intervals variables "foottimes", "nfoottimes" and "nftpix" are computed in setStiltparam.r 
      if(ftintr>1){	
        nfoottimes <- -nhrs/ftintr+2               #number of footprints computed
        foottimes<-rep(c(0),nfoottimes)            #vector of times (backtimes) in hours between which footprint is computed
        nftpix<-rep(c(0),nfoottimes)               #vector of numbers of pixels in each footprint
        for(ft in 2:nfoottimes){ 
          foottimes[ft]<- hr+(ft-2)*ftintr 
        }
        foottimes[nfoottimes]<- -nhrs
        if(hr==0){				 #special case when starting at midnight
          foottimes<-foottimes[2:nfoottimes]
          nftpix<-nftpix[2:nfoottimes]
          nfoottimes<-nfoottimes-1
        }
      }

      ####### call Trajecfoot ############################ 
      ident<-identname
      foot <- Trajecfoot(ident, pathname=path, foottimes=foottimes, zlim=c(zbot, ztop),fluxweighting=NULL, coarse=1, vegpath=vegpath,
                         numpix.x=numpix.x, numpix.y=numpix.y,lon.ll=lon.ll, lat.ll=lat.ll, lon.res=lon.res, lat.res=lat.res)
      nameslat<-rownames(foot)
      nameslon<-colnames(foot)
  #    print(paste("nameslat, nameslon: ",nameslat, nameslon))
      if(is.null(foot)){
        print(paste("is.null(foot): ",is.null(foot),foot))
        print(paste("No binary footprint file for TM3 written!!!!"))

      } else {

    #    #### write the output file ####
    #    cyr<-as.character(2000+yr)
    #    cmon<-as.character(mon)
    #    cday<-as.character(day)
    #    chr<-as.character(hr)
    #    x1<-""; x2<-""; x3<-""
    #    if(mon<10) x1<-paste(x1,"0",sep="")
    #    if(day<10) x2<-paste(x2,"0",sep="")
    #    if(hr<10)  x3<-paste(x3,"0",sep="")
    #
    #    pathBinFootprintstation<-paste(pathBinFootprint,station,"/",sep="")
    #    if (file.access(pathBinFootprintstation,0)!=0) {
    #     system(paste("mkdir ",pathBinFootprintstation,sep=""))
    #     }
    #
    ##    filename<-paste(pathBinFootprintstation,station,"_",as.character(-nhrs),"h0",as.character(ftintr),
    ##                    "h_",cyr,x1,cmon,x2,cday,x3,chr,"_",gridtag,cendian,".d",sep="")
    ## Jan's version with height in filename
    #    filename<-paste(pathBinFootprintstation,station,"_",as.character(-nhrs),"h0",as.character(ftintr),
    #                    "h_",cyr,x1,cmon,x2,cday,x3,chr,"_",sprintf("%5.5d",as.integer(agl)),"_",gridtag,cendian,".d",sep="")

        print(paste("Writing binary footprint file: ",filename))
        con<-file(filename, "wb")
    # write first: hours backward, hours interval, lat, lon, altitude, lat resolution, and lon resolution
        writeBin(as.numeric(c(nhrs,ftintr,lat,lon,agl,lat.res,lon.res)),con,size=4,endian=endian) 

        nftpix<-apply(foot,c(3),function(x)return(sum(x>0)))
        ftmax<-which(nftpix>0)[sum(nftpix>0)]
        for(ft in 1:(nfoottimes-1)){
          writeBin(as.numeric(c(ft,nftpix[ft])),con,size=4,endian=endian)          # index of footprint and # grids in footprint
          #### pixel by pixel #####
          if(nftpix[ft]>0){
            id<-which((foot[,,ft])>0,arr.ind=T)
            foot_data<-cbind(as.numeric(nameslat[id[,1]]),as.numeric(nameslon[id[,2]]),foot[,,ft][id])# save coordinates of pixels of each footprint and footprint value
            foot_data<-foot_data[order(foot_data[,1],foot_data[,2]),]
            if(nftpix[ft]==1)foot_data<-matrix(foot_data,nrow=1) #convert back to matrix; ordering turned one-row matrices into vectors
            writeBin(as.vector(t(foot_data)),con,size=4,endian=endian)
            if(any(foot_data[,3]<0))browser()
          } #if(nftpix[ft]>0)
        } #for(ft   
        print(paste("ftmax: ",ftmax))

        close(con)
      } #if is.null(foot) 

      } else {
        print(paste(path,outname," does exist -> no new STILT run !!",sep=""))
      } #if (file.exists(paste(path,outname,sep=""))) 

    } #if (file.exists(filename))


  }  #end if(writeBinary == T)

  ###### end of TM3-STILT output ################
  #########################################################################

  #########################################################################
  ##### map trajectories to flux grids and vegetation maps ################
  ##### calculate mixing ratios at receptor points, save in result ########
  if (fluxTF) {
     if (j2>j1) stop ('non-unity partperhymodelc not supported for fluxTF=TRUE')
     print(paste("Trajecmod(): rownumber j:", j1))


     traj <- Trajecvprm(ident=identname, pathname=path, tracers=fluxtracers, coarse=aggregation,
                dmassTF=T, nhrs=nhrs, vegpath=vegpath, evilswipath=evilswipath,
                vprmconstantspath=vprmconstantspath, vprmconstantsname=vprmconstantsname, nldaspath=nldaspath,
                nldasrad=usenldasrad, nldastemp=usenldastemp, pre2004=pre2004,
                keepevimaps=keepevimaps, detailsTF=detailsTF, bios=fluxmod, landcov=landcov,
                numpix.x=numpix.x, numpix.y=numpix.y, lon.ll=lon.ll, lat.ll=lat.ll,
                lon.res=lon.res, lat.res=lat.res,doubletimeTF=doubletimeTF)

     if(cpTF){
       #=====================use trajwind.r 
       if(modelwind){
         trajnames<-c(names(traj),"ubar","vbar","wbar","wind.dir")
         traj<-c(t(traj),ubar,vbar,wbar,dir);
         names(traj)<-trajnames
       }
       #=====================end trajwind.r 
     }
         
     # 'traj' is a vector
     if (existsr(paste(stiltresultname, part, sep=""), path=path_stiltresult)) {
        result <- getr(paste(stiltresultname, part, sep=""), path=path_stiltresult)
        if (dim(result)[1] != nrows) {
           if (firstflux) print("Trajecmod(): existing stiltresult has wrong dimension; creating new one.")
        } else {
           if (firstflux) print("Trajecmod(): found existing stiltresult, update rows in that.")
           firstflux <- FALSE
        }
     }
     if (firstflux) { # at beginning create result object
        ncols <- length(traj) # all from Trajec(), + 3 from StartInfo (agl, lat, lon)
        result <- matrix(NA, nrow=nrows, ncol=ncols)
        firstflux <- F
     }
     result[rownum, ] <- traj
     dimnames(result) <- list(NULL, c(names(traj)))
     dimnames(result) <- list(NULL, dimnames(result)[[2]])
     # write the object into default database; object names are, e.g., "Crystal.1"
     assignr(paste(stiltresultname, part, sep=""), result, path=path_stiltresult)
  }
  rownum <- rownum+1

  if(cpTF){
##### calculate footprint, assign in object ########
    path_foot <- pathFP     # to keep in sync with default 
    if (footprintTF) {
      rerunfoot <- FALSE
      if(existsr(paste("foot", identname, sep=""),pathFP)){
         #print(paste("Trajecmod(): found object", paste("foot", identname, sep=""), " in ", pathFP))
         cat(format(Sys.time(), "%FT%T"),"DEBUG Trajecmod(): found object: foot", identname)
         print(pathFP)
         print(identname)
         foot <- getr(paste("foot", identname, sep=""), pathFP)
         print(" test if object has same foottimes, if not rerun Trajecfoot")
         # test if object has same foottimes, if not rerun Trajecfoot
         foothr <- as.numeric(dimnames(foot)[[3]])
         if (!all(foothr==foottimes[1:(length(foottimes)-1)])) {
           rerunfoot<-TRUE
           print(paste("; but dimensions do not match.\n"))
         } else {
           print(paste("; use this.\n"))
         }
      } else {
         rerunfoot <- TRUE
      }

      if (rerunfoot) {
         #print(paste("Trajecmod(): ", identname, " running footprint at ", unix("date"), sep=""))
         cat(format(Sys.time(), "%FT%T"),"DEBUG Trajecmod(): ", identname, " running footprint at ",format(Sys.time(), "%d %b %Y %H:%M:%S"),"\n")
         #print(paste("Trajecmod(): memory in use:", memory.size()[1]))
         foot <- Trajecfoot(identname, pathname=path, foottimes=foottimes, zlim=c(zbot, ztop),
                            fluxweighting=NULL, coarse=1, vegpath=vegpath,
                            numpix.x=numpix.x, numpix.y=numpix.y,
                            lon.ll=lon.ll, lat.ll=lat.ll, lon.res=lon.res, lat.res=lat.res)
         # uk check if foot is valid
         #if (is.null(dim(foot))) stop(paste(" Trajecfoot returned empty footprint for ",identname,sep=""))
         if (!is.null(foot)) {
           assignr(paste("foot", identname, sep=""), foot, pathFP)
             cat(format(Sys.time(), "%FT%T"),"DEBUG Trajecmod(): foot", identname, " assigned\n")
         } #if (!is.null(dim(foot)))
      } # if (rerunfoot)

      if (is.null(foot)) { # uk check if foot is valid
        cat(format(Sys.time(), "%FT%T"),"ERROR Trajecmod(): Trajecfoot returned empty footprint for ",identname, " No footprint file written!!!\n")
      } else {	    
      # write aggregated footprint to netcdf file
      # prepare for ncdf output 
      if (ftintr > 0 | length(foottimes) > 10) {
        ncf_name <- paste("foot",identname,".nc",sep="")
      } else {
        ncf_name <- paste("foot",identname,"_aggreg.nc",sep="")
      }
      print(ncf_name)
      require("ncdf4")
      epoch <- ISOdatetime(2000,1,1,0,0,0,"UTC")
      digits=10
      fac.dig <- 1+10^(-digits)
      errors <- NULL
	    
      # foot has dimensions lat,lon,(backward-)time
      # introduce initial time as time dimension (needed to contruct yearly files with aggregated footprints)
      # define backward time as 4th dimension
      # latitude and longitude are defined at the lower left corner of the grid cells
      # also in .RDatafoot output
      # but need to be shifted for output in netcdf files
      #  
      footlon <- as.numeric(dimnames(foot)[[2]])+(as.numeric(lon.res)/2.)
      footlat <- as.numeric(dimnames(foot)[[1]])+(as.numeric(lat.res)/2.)
      foothr <- 1
      footbhr <- as.numeric(dimnames(foot)[[3]])
      # shift footbhr to represent start time of integration rather than end time
      # assuming that first integration intervall ends at initial time
      footbhr <- foottimes[2:(length(foottimes))]
      hr <- round((StartInfo[j1,1]-floor(StartInfo[j1,1]))*24)
      inittime<-ISOdatetime(dat$year,dat$month,dat$day,hr,0,0,tz="UTC")
      foottime <- inittime-footbhr*3600

      footdate <- as.numeric(difftime(inittime,epoch,units="days")) # subtract the epoch to make days-since
      footbdate <- as.numeric(difftime(foottime,epoch,units="days")) # subtract the epoch to make days-since

      # if netcdf file does not exist or has different content, write new netcdf file
      if (file.exists(paste(pathFP,ncf_name,sep=""))) {
        cat(format(Sys.time(), "%FT%T"),"DEBUG Trajecmod(): found netcdf file ", ncf_name,"\n")
        ncf <- nc_open(paste(pathFP,ncf_name,sep=""))
          cat(format(Sys.time(), "%FT%T"),"DEBUG Trajecmod(): found netcdf file ", ncf_name, " in ", pathFP,"\n")
          #cat(format(Sys.time(), "%FT%T"),"DEBUG open ",ncf,"\n")
        for( i in 1:ncf$nvars ) {
          z <- ncf$var[[i]]
          if (z$name=="foot") testfoot<-ncf$var[[i]]
        }

        zfoot <- ncvar_get( ncf, testfoot )
        if(compare.signif(zfoot,drop(aperm(foot,c(2,1,3))),digits,fac.dig) !=0) errors <- c(errors,'foot mismatch')
        cat(format(Sys.time(), "%FT%T"),"DEBUG ",paste(errors,sep=" "),"\n")
        nc_close(ncf)
        if (!is.null(errors)) {
           cat(format(Sys.time(), "%FT%T"),"DEBUG ; but content does not match.\n")
           cat(format(Sys.time(), "%FT%T"),"DEBUG ; mismatch in ",errors,"\n")
        } else {
           cat(format(Sys.time(), "%FT%T"),"DEBUG ; use this.\n")
        }
      }
      if (!file.exists(paste(pathFP,ncf_name,sep="")) | !is.null(errors)) {
        # dimensions for netcdf file
        footlon.dim <- ncdim_def( "lon", "degrees_east", footlon, longname="degrees longitude of center of grid boxes" )
        footlat.dim <- ncdim_def( "lat", "degrees_north", footlat, longname="degrees latitude of center of grid boxes"  )
        footdate.dim <- ncdim_def( "time", "days since 2000-01-01 00:00:00 UTC", footdate, longname="footprint initial date",unlim=TRUE )
        #footbdate.dim <- ncdim_def( "back", "days since 2000-01-01 00:00:00 UTC", footbdate, longname="footprint intervalls backward time" )

        # missing values
        mv <- -1.e30 # missing value to use
        # define variable
        # compress is not working... hdf5 not correctly installed/linked?
        #footprint <- ncvar_def( "foot", "ppm per (micromol m-2 s-1)", list(footbdate.dim,footlon.dim,footlat.dim,footdate.dim), mv, longname="STILT footprints integrated over backward time intervall btime-time" , prec="double", compression=9)
        footprint <- ncvar_def( "foot", "ppm per (micromol m-2 s-1)", list(footlon.dim,footlat.dim,footdate.dim), mv, longname="STILT footprints integrated over backward time intervall backtime" , prec="double", compression=9)

        # Create output file
        ncf <- nc_create( paste(pathFP,ncf_name,sep=""), list(footprint) )

        # write data to the file
        #rearange dimensions for netcdf because netcdf standard requires lon,lat,time, use btime as 4th dimension
        footT<-aperm(foot,c(2,1,3))   
        #footT<-array(footT,dim=c(dim(footT)[3],dim(footT)[1],dim(footT)[2],1))
        #ncvar_put( ncf, footprint, footT, start=c(1,1,1,1), count=c(-1,-1,-1,-1) )
        ncvar_put( ncf, footprint, footT, start=c(1,1,1), count=c(-1,-1,-1) )

        # add attributes
        ncatt_put( ncf, 0, "backtime",paste(-nhrs,"hours",sep=" ") )
        ncatt_put( ncf, 0, "description",
                        paste("aggregated STILT footprints on lon/lat/time grid,",
  		              "aggregated in grid boxes (lat,lon) and stilt start time (time),",
  			      "aggregated over backtime hours prior to start time") )
        nc_close(ncf)
        cat(format(Sys.time(), "%FT%T"),"DEBUG Footprint written to NetCDF file ",ncf_name,"\n")
       } 
    } # !is.null(foot) 
    } # footprintTF

  } else {
    ##### calculate footprint, assign in object ########
    if (footprintTF) {
       if (j2>j1) stop ('non-unity partperhymodelc not supported for footprintTF=TRUE')
       print(paste("Trajecmod(): ", identname, " running footprint at ", unix("date"), sep=""))
       print(paste("Trajecmod(): memory in use:", memory.size()[1]))
       foot <- Trajecfoot(identname, pathname=path, foottimes=foottimes, zlim=c(zbot, ztop),
                          fluxweighting=NULL, coarse=1, vegpath=vegpath,
                          numpix.x=numpix.x, numpix.y=numpix.y,
                          lon.ll=lon.ll, lat.ll=lat.ll, lon.res=lon.res, lat.res=lat.res)
       assignr(paste("foot", identname, sep=""), foot, path_foot)
       print(paste("Trajecmod(): foot", identname, " assigned", sep=""))
    } # if (exists(foottimes))
  }
  
  ##### plot footprint ########
  if (footplotTF) { # plot footprints
    if (j2>j1) stop ('non-unity partperhymodelc not supported for footplotTF=TRUE')
    foot <- getr(paste("foot", identname, sep=""), path_foot)
    footplot(foot,identname,lon.ll,lat.ll,lon.res,lat.res)
    for (foottimespos in 1:(length(foottimes)-1)) {
    ############# NOT READY YET ###############
    }
  }

  # Specify the function parameters
  if (biomassburnTF) {
     if (j2>j1) stop ('non-unity partperhymodelc not supported for biomassburnTF=TRUE')
     biomassburnoutmat[j1, ] <- biomassburn(timesname=StartInfo, burnpath=burnpath, endpath=path, pathname=path, nhrs=nhrs, timesrow=j1)
     print(paste("Biomassburning influence calculated to be ", biomassburnoutmat[j1,2], " ppbv. Inserted into fireinfluence matrix row ", j1, sep=""))
  }

  if(l.remove.Trajfile)unix(paste("rm -f ",paste(path,".RData",identname,sep=""),sep=""))

  j1 <- j2+1 #increment row counter
}                                                           # for (j in 1:nrows)


# Wrap up all of the CO biomassburning calculations
if (biomassburnTF)
  write.table(biomassburnoutmat, file=paste(path, "fireinfluencex", nhrs, "hr_", part, ".txt", sep=""), row.names=F)

##### save mixing ratios at receptor points in file, e.g. stiltresult1.csv for part=1 ########
if (fluxTF) {
   dimnames(result) <- list(NULL, dimnames(result)[[2]])
   # write the object into default database; object names are, e.g., "Crystal.1"
 
   assignr(paste(stiltresultname, part, sep=""), result, path=path_stiltresult)
   print(paste(stiltresultname, part, " assigned in ", path_stiltresult, sep=""))

   if (cpTF){                  # ICOS-CP specific settings
      # Add information on model version, fluxes and tracer metadata to csv file
      # Convert the matrix result to a data frame
      df_result <- data.frame(result)
      #add colum names separately to prevent some automatic changes of '+' into '.'
      col_names_df <- dimnames(result)[[2]]
      colnames(df_result) <- col_names_df
      # Add the new column with metadata link to the data frame
      df_result$metadata <- metadata
      write.table(df_result, file=paste(path_stiltresult, stiltresultname, part, ".csv", sep=""), na="", row.names=F)
   }else{
      write.table(result, file=paste(path_stiltresult, stiltresultname, part, ".csv", sep=""), na="", row.names=F)
   }
}
# If evi and lswi maps from vprm calculations is saved to the global environment; it should be removed here

rm(list=objects(pattern="GlobalEvi"), envir=globalenv())
rm(list=objects(pattern="GlobalLswi"), envir=globalenv())
gc(verbose=F)

return(run.info)

}

compare.signif <- function(x,y,digits=6,fac.dig=1+10^(-digits)) {
  # comparison of f.p. numbers to within specified significant digits
  # Uses signif function, but with added handling of rounding of 5
  mask <- signif(x,digits) != signif(y,digits)
    nfail <- sum(mask)
    if (nfail > 0)
      nfail <- sum(signif(fac.dig*x[mask],digits) != signif(fac.dig*y[mask],digits))
    nfail
}
