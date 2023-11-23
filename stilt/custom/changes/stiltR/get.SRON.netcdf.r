#***************************************************************************************************
#  read initial values from CarbonTracker file and attach them to the "result" matrix
#***************************************************************************************************

get.SRON.netcdf <- function(yr4=NULL, mon=NULL, day=NULL, hr=NULL, tracersinifile=NULL,
                             result=NULL, result.sel=NULL,tracer="co2") {

# --------------------------------------------------------------------------------------------------
#  Interface
#  =========
#
#  yr4          YYYY of the receptor time
#  mon          month "
#  day          day   "
#  hr           hour  "
#  tracersinifile   netCDF file name (absolute path) of the TM3 analyzed fields
#  result       matrix with columns "btime", "lat", "lon" and "pres"
#               gets the column "co2ini" attached/overwritten on output
#  result.sel   selector of same length as the columns of "result": which rows should be considered
#
# --------------------------------------------------------------------------------------------------
#  $Id: get.TM3.netcdf.r,v 1.1 2009-02-24 14:27:54 gerbig Exp $
# --------------------------------------------------------------------------------------------------


  require("ncdf4") # Load ncdf4 library
  refdate <- month.day.year(floor(julian(mon, day, yr4) + hr/24 - result[result.sel, "btime"]/24))

   #check which files are there
  #tracersinifiles<-dir(dirname(tracersinifile),full.names=T,pattern="z_cams_l_tno-sron_v17r1s_ra_ml_6h_ch4_.....nc")
  #tracersinifiles<-dir(dirname(tracersinifile),full.names=T,pattern="cams73_v18r1_ch4_conc_surface_satellite_inst_.....nc")
  tracersinifiles<-dir(dirname(tracersinifile),full.names=T,pattern="cams73_latest_ch4_conc_surface_inst_.....nc")

   #print(tracersinifiles)
   
   ncharafteryear<-3; #if(grepl("_fg.nc",tracersinifile))ncharafteryear<-6
   years.avail<-as.numeric(substring(tracersinifiles,nchar(tracersinifiles)-ncharafteryear-3,nchar(tracersinifiles)-ncharafteryear))
   years.avail<-years.avail[!is.na(years.avail)]
   #print(years.avail)
   #print(ncharafteryear)
   years.avail<-years.avail[!is.na(years.avail)]
   
   for(yeari in unique(refdate$year)){
      selm<-refdate$year==yeari
      resultm<-result[selm,]
      result.selm<-result.sel[selm]
      if(yeari>max(years.avail)){#limit to last available file
         print(paste("NOTICE: data in ",dirname(tracersinifile)," only until ",max(years.avail),"; replaced more recent years by ",max(years.avail),sep=""))
         yeari<-max(years.avail)
      }
      if(ncharafteryear==3)tracersinifilem<-paste(substring(tracersinifile,1,nchar(tracersinifile)-ncharafteryear-4),yeari,".nc",sep="")
      if(ncharafteryear==6)tracersinifilem<-paste(substring(tracersinifile,1,nchar(tracersinifile)-ncharafteryear-4),yeari,"_fg.nc",sep="")
      print(paste("getSRON:", tracersinifilem))
      tm3file <- nc_open(tracersinifilem, write=F,readunlim=FALSE)
      
      # Lines added SBOTIA to read SRON files 
      if (tracer=="ch4"){
          centerlats <- ncvar_get(tm3file, varid="latitude")    # Center
          centerlons <- ncvar_get(tm3file, varid="longitude")    # Center
          times <- ncvar_get(tm3file, varid="time")        # Center (instantaneous)
          levs <- ncvar_get(tm3file, varid="hlevel")       # levels
      }else{
          centerlats <- ncvar_get(tm3file, varid="lat")    # Center
          centerlons <- ncvar_get(tm3file, varid="lon")    # Center
          times <- ncvar_get(tm3file, varid="time")        # Center (instantaneous)
          levs <- ncvar_get(tm3file, varid="height")       # levels          
      }
      # Lines added SBOTIA to read SRON files,end 

#      print("NO PROB READING THE NC FILE") # DEBUG   
      nlevs<-length(levs)

      if(tracer=="co2")ini <- ncatt_get(tm3file, varid="co2mix",attname="ini")$value # global CO2 offset
      if(tracer!="co2")ini <- 0
      # Get Ending positions
      agl4ct <- resultm[result.selm, "agl"]+resultm[result.selm, "grdht"]
      lat4ct <- resultm[result.selm, "lat"]
      lon4ct <- resultm[result.selm, "lon"]

      #-- lat lon pointer
      dlat<-unique(round(diff(centerlats),4))
      dlon<-unique(round(diff(centerlons),4))
      latpt<-round((lat4ct-rep(centerlats[1],times=length(lat4ct)))/rep(dlat,times=length(lat4ct)))+1
      lonpt<-round((lon4ct-rep(centerlons[1],times=length(lon4ct)))/rep(dlon,times=length(lon4ct)))+1
      point<-cbind(lonpt,latpt) #spatial pointer (2D)


      # Bugfix, Mike Galkowski, July 2020 ====================================
      # Broken time pointer at the year-shift
      # Fixed by calculating POSIX dates and searching the smallest difference
      # Added additional quality checks for delt.h values

      #delt.h<-(times[2]-times[1])/3600
      #timept<-round((julian(mon, day, yr4) + hr/24 - resultm[result.selm, "btime"]/24-julian(1, 1, yr4))*24/delt.h+1+0.01)#+0.01 to avoid round bug
      #timept[timept<1]<-1 #default to first
      #timept[timept>length(times)]<-length(times) #default to last

      # a) Quality checks on delt.h introduced
      delt.h <- times[2:length(times)] - times[1:(length(times)-1)]
      delt.h <- unique(delt.h)/3600
      if( length( delt.h ) != 1 ){ stop("Time differences in the netcdf file are not equal!") }
      if( delt.h < 0 ){ stop("Time index descending in the netcdf file. Ascending order expected.") }

      # b) Main bugfix. Note: POSIX (aka ISO) dates are always given in seconds. 
      SRON_nc_times_posix <- ISOdate(yeari,01,01,00,tz="UTC") + times*3600
      release_date <- ISOdate(yr4, mon, day, hr, tz = "UTC" )
      boundary_reached_dates <- release_date - resultm[result.selm, "btime"]*3600
      timept <- sapply( boundary_reached_dates, function(x) {which.min( abs(x-SRON_nc_times_posix) ) } )
      # End of bugfix ========================================================


      tm3boundary <- rep(NA, length(timept))
#      print("BeforeLOOP") # DEBUG   
      # loop over unique end times
      for (time.i in unique(timept)) {
         ctsel <- which(timept == time.i)
         if(length(ctsel)==1){
           #get height from geostrophic height
#           print("THIS IS INSIDE FIRST IF IN LOOP") # SBOTIA  
           gph<-ncvar_get(tm3file, varid="altitude", start=c(point[ctsel,],1, time.i),count=c(1,1,nlevs,1))
           lev<-findInterval(agl4ct[ctsel], c(0,gph[-1]), rightmost.closed=TRUE,all.inside=TRUE)
           tm3boundary[ctsel] <- ini+ncvar_get(tm3file, varid=toupper(tracer), start=c(point[ctsel,],lev, time.i),count=c(1,1,1,1))
             
           #tm3boundary[ctsel] <- ini+ncvar_get(tm3file, varid=paste(tracer,"mix",sep=""), start=c(point[ctsel,],lev, time.i),count=c(1,1,1,1))

         } else { #more than one element to extract
#           print("THIS IS INSIDE the first ELSE IN LOOP") # SBOTIA 
           #DEBUG
#           print(ctsel)  
           #DEBUG
           start.rd<-apply(point[ctsel,],2,min)
           count.rd<-apply(point[ctsel,],2,max)-start.rd + c(1,1)
           count.rd[count.rd<2]<-2 #read at least 2 items per dimension to have right overall dimension in object
           
           # debug  
           #print(class(start.rd))
           #print(start.rd)
           #print(class(count.rd))
           #print(count.rd)
           #print(time.i)
           #print(nlevs) 
           #print(c(start.rd, 1, time.i))
           # debug
             
           if(start.rd[1]+count.rd[1]-1>length(centerlons)){
              # stepping over dateline, need to read in last then first long. elements 
#              print("THIS IS INSIDE SECOND IF IN LOOP") # SBOTIA 
              count.rda<-count.rd;count.rdb<-count.rd;
              start.rda<-start.rd;start.rdb<-start.rd;
              count.ex<-(start.rd[1]+count.rd[1]-1-length(centerlons))
              count.rda[1]<-count.rda[1]-count.ex
              start.rdb[1]<-(start.rd[1]+1)%%length(centerlons)
              count.rdb[1]<-count.rd[1]-count.rda[1]

              gpha <- ncvar_get(tm3file, varid="altitude", start=c(start.rd, 1, time.i),count=c(count.rda,nlevs,1))
              gphb <- ncvar_get(tm3file, varid="altitude", start=c(start.rdb, 1, time.i),count=c(count.rdb,nlevs,1))
              if(length(dim(gpha))<3)gpha<-array(gpha,dim=c(1,dim(gpha)))
              if(length(dim(gphb))<3)gphb<-array(gphb,dim=c(1,dim(gphb)))
              require(abind)
              gph<-abind(gpha,gphb,along=1)
           } else {
#              print("THIS IS INSIDE SECOND ELSE IN LOOP") # SBOTIA 
              gph <- ncvar_get(tm3file, varid="altitude", start=c(start.rd, 1, time.i),count=c(count.rd,nlevs,1))
#              print("THIS IS INSIDE SECOND ELSE IN LOOP and able to read altitude...") # SBOTIA 
           }
           gph[,,1]<-0 #set lowest level to zero
           hpt<-point[ctsel,1]*NA
           hpt[is.na(hpt)]<-1
           pt3d<-cbind(point[ctsel,],hpt) #turn into 3 D pointer
           point[ctsel,1]<-point[ctsel,1]-start.rd[1]+1#for use in gph as pointer
           point[ctsel,2]<-point[ctsel,2]-start.rd[2]+1
#           print("AFTER SETTING 3D POINTER AND SECOND LOOP")
           for(l in 1:dim(gph)[3]){
             gphi<-gph[,,l][point[ctsel,]]
             pt3d[,"hpt"][agl4ct[ctsel]>gphi]<-l
           }
           start.rd<-apply(pt3d,2,min)
           count.rd<-apply(pt3d,2,max)-start.rd + c(1,1,1)
           pt3d<-pt3d+matrix(-start.rd+c(1,1,1),nrow=nrow(pt3d),ncol=ncol(pt3d),byrow=TRUE) #offset correction, to extract from small array to be read from ncdf
#           print("before last two ifs")  
           if(any(count.rd>1)) tm3boundary[ctsel] <- ini+ncvar_get(tm3file, varid=toupper(tracer), start=c(start.rd, time.i),count=c(count.rd,1))[pt3d[,count.rd>1]]
           if(!any(count.rd>1))tm3boundary[ctsel] <- ini+ncvar_get(tm3file, varid=toupper(tracer), start=c(start.rd, time.i),count=c(count.rd,1)) #only one value  
             
           #if(any(count.rd>1)) tm3boundary[ctsel] <- ini+ncvar_get(tm3file, varid=paste(tracer,"mix",sep=""), start=c(start.rd, time.i),count=c(count.rd,1))[pt3d[,count.rd>1]]
           #if(!any(count.rd>1))tm3boundary[ctsel] <- ini+ncvar_get(tm3file, varid=paste(tracer,"mix",sep=""), start=c(start.rd, time.i),count=c(count.rd,1)) #only one value
         }
      }
      
#      print("OUT OF THE LOOP and FINISHING")
      resultm[,paste(tracer,"ini",sep="")] <- rep(0,nrow(resultm))
      resultm[result.selm,paste(tracer,"ini",sep="")] <- tm3boundary/1000.    # CP: convert ppb to ppm (CAMS is in ppb but all other CH4 components are converted in ppm)

      nc_close(tm3file)

      result[selm,paste(tracer,"ini",sep="")] <- resultm[,paste(tracer,"ini",sep="")]
   } #loop over months

   return(result)

}
