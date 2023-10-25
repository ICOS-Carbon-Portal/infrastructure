#Reformat STILT results
#source("/Net/Groups/BSY/people/cgerbig/Rsource/CarboEurope/stiltR.bialystok/lookstilt.r")
#6/12/2016 by UK

station <- Sys.getenv(c("STILT_NAME"), unset = NA)
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: selected station: ",station,"\n")
run_id <- Sys.getenv(c("RUN_ID"),unset = NA)
stilt_year <- Sys.getenv(c("STILT_YEAR"),unset = NA)

tp <- Sys.getenv(c("STILT_TOTPART"),unset = NA)  # number of parts 

# settings for CarbonPortal
#large EU2 region
lon.res <- 1/8                 #resolution in degrees longitude
lat.res <- 1/12                #resolution in degrees latitude
lon.ll  <- -15                 #lower left corner of grid
lat.ll  <-  33                 #lower left corner of grid
fluxmod <- "VPRM"
landcov <- "SYNMAP.VPRM8"

path<-paste("./Output/",run_id,"/RData/",station,"/",sep="")
pathFP<-paste("./Output/",run_id,"/Footprints/",station,"/",sep="")
sourcepath<-"./stiltR/";source(paste(sourcepath,"sourceall.r",sep=""))#provide STILT functions
pathResults<-paste("./Output/",run_id,"/Results/",station,"/",sep="")

Timesname<-paste(".",station,".",stilt_year,".request",sep="")
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: Timesname ",Timesname,"\n")
StartInfo <- getr(paste(Timesname, sep=""), pathResults) # object containing fractional julian day, lat, lon, agl for starting position and time
identname <- pos2id(StartInfo[1,1],StartInfo[1,2],StartInfo[1,3],StartInfo[1,4])
stiltresultname <- paste("stiltresult",stilt_year,substr(identname,14,34),sep="")
cat(format(Sys.time(), "%FT%T"),"INFO new result filename: ",stiltresultname,"\n")

#merge STILT result objects  ## not used at them moment in CP version 
rnam<-stiltresultname
dat<-NULL
for(part in 1:tp){
dat<-rbind(dat,getr(paste(rnam,"_",part,sep=""),pathResults))} #standard simulation

cat(format(Sys.time(), "%FT%T"),"DEBUG reform: part ",part,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: dim(dat) ",dim(dat),"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: dimnames(dat) ",paste(dimnames(dat),sep=" "),"\n")
mdy<-month.day.year

getmdy<-function(fjday){#nice x axis
MDY<-mdy(floor(fjday))
#get date and time formatted; setting sec to 0.1 avoids skipping the time for midnight
return(ISOdate(MDY$year, MDY$month, MDY$day, hour = round((fjday-floor(fjday))*24), 
       min = 0, sec = 0.0, tz = "GMT"))
}

startdate<-format(getmdy(min(StartInfo[,1])),'%Y%m%d')
enddate<-format(getmdy(max(StartInfo[,1])),'%Y%m%d')
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: startdate: ",startdate,"  enddate: ",enddate,"\n")

list_FP<-dir(pathFP,all.files=T)
list_FP<-list_FP[(nchar(list_FP)==44) & (substring(list_FP,2,10)=="RDatafoot")]
ident_time<-substring(list_FP,nchar(list_FP)-33,nchar(list_FP))
ident_test<-pos2id(dat[,1],dat[,2],dat[,3],dat[,4])
good<-(ident_test %in% ident_time)
dat<-dat[good,,drop=F]
dat<-unique(dat)

ymdh<-getmdy(dat[,1])
MDY<-mdy(floor(dat[,1]))
year<-MDY$year
month<-MDY$month
day<-MDY$day
hour<-round((dat[,1]-floor(dat[,1]))*24)

zi<-dat[,"zi"]
dat2<-dat[,1:4,drop=F]
isodate<-as.numeric(as.POSIXct(ymdh))
date<-format(ymdh,'%Y/%m/%d#%H:%M')
dat2<-cbind(date,isodate,year,month,day,hour,dat2,zi)

#character to real ...
nms<-dimnames(dat)
dat<-matrix(as.numeric(dat),ncol=length(dimnames(dat)[[2]]),dimnames=nms)

tracer<-"rn"
rn.stilt<-dat[,"rn"]
#rn.stilt<-dat[,"rnini"]+dat[,"rn"]
rn<-rn.stilt
rn.noah<-dat[,"rn_noah"]
rn.era<-dat[,"rn_era"]
rn.const<-dat[,"rn_const"]
rn.noah2<-dat[,"rn_n2"]
rn.era5<-dat[,"rn_e5"]
rn.noah2_m<-dat[,"rn_n2m"]
rn.era5_m<-dat[,"rn_e5m"]
#rn.noah<-dat[,"rnini"]+dat[,"rn_noah"]
#rn.era<-dat[,"rnini"]+dat[,"rn_era"]
#rn.const<-dat[,"rnini"]+dat[,"rn_const"]
#rn.noah<-dat[,"rn_noahini"]+dat[,"rn_noah"]
#rn.era<-dat[,"rn_eraini"]+dat[,"rn_era"]
#rn.const<-dat[,"rn_constini"]+dat[,"rn_const"]
rn.background<-dat[,"rnini"]

tracer<-"co2"

pars<-matrix(NA, ncol=3, nrow=lengths(dimnames(dat)[2]))
colnames(pars)<-c("trac", "cats", "fuels")
for(i in 1:lengths(dimnames(dat)[2])){
  fls<-strsplit(dimnames(dat)[[2]][i], split=".", fixed=T) #fls[[1]][3] 
  pars[i,]<-fls[[1]][1:3]
}
ucats<-unique(pars[,"cats"])  #length: 22
ufs<-unique(pars[,"fuels"])   #length: 13
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: ucats ",ucats,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: ufs ",ufs,"\n")

selco2<-pars[(pars[,1]==tracer & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
co2.cat.fuel.all<-rowSums (dat[,paste(selco2[,1],selco2[,2],selco2[,3],sep="."),drop=F], na.rm = FALSE)

selco2bio<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="bio" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2gas<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="gas" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2coal<-pars[(pars[,1]==tracer & substring(pars[,3],1,4)=="coal" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2oil<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="oil" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2waste<-pars[(pars[,1]==tracer & substring(pars[,3],1,11)=="solid_waste" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

co2.cat.fuel.all<-rowSums (dat[,paste(selco2[,1],selco2[,2],selco2[,3],sep="."),drop=F], na.rm = FALSE)
co2.cat.fuel.bio<-rowSums (dat[,paste(selco2bio[,1],selco2bio[,2],selco2bio[,3],sep="."),drop=F], na.rm = FALSE)
co2.cat.fuel.gas<-rowSums (dat[,paste(selco2gas[,1],selco2gas[,2],selco2gas[,3],sep="."),drop=F], na.rm = FALSE)
co2.cat.fuel.coal<-rowSums (dat[,paste(selco2coal[,1],selco2coal[,2],selco2coal[,3],sep="."),drop=F], na.rm = FALSE)
co2.cat.fuel.oil<-rowSums (dat[,paste(selco2oil[,1],selco2oil[,2],selco2oil[,3],sep="."),drop=F], na.rm = FALSE)
co2.cat.fuel.waste<-rowSums (dat[,paste(selco2waste[,1],selco2waste[,2],selco2waste[,3],sep="."),drop=F], na.rm = FALSE)

selco2energy<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a1a","1a1bcr")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2transport<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a3b","1a3ce","1a3a+1c1","1a3d+1c2")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2industry<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a2+6cd","2a","2befg+3","2c")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2others<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1b2abc","7a","4f")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selco2resident<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a4")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

co2.energy<-rowSums (dat[,paste(selco2energy[,1],selco2energy[,2],selco2energy[,3],sep="."),drop=F], na.rm = FALSE)
co2.industry<-rowSums (dat[,paste(selco2industry[,1],selco2industry[,2],selco2industry[,3],sep="."),drop=F], na.rm = FALSE)
co2.transport<-rowSums (dat[,paste(selco2transport[,1],selco2transport[,2],selco2transport[,3],sep="."),drop=F], na.rm = FALSE)
co2.others<-rowSums (dat[,paste(selco2others[,1],selco2others[,2],selco2others[,3],sep="."),drop=F], na.rm = FALSE)
co2.residential<-rowSums (dat[,paste(selco2resident[,1],selco2resident[,2],selco2resident[,3],sep="."),drop=F], na.rm = FALSE)

dat<-cbind(dat,co2.cat.fuel.all,co2.cat.fuel.bio,co2.cat.fuel.gas,co2.cat.fuel.coal,co2.cat.fuel.oil,co2.cat.fuel.waste,co2.energy,co2.transport,co2.industry,co2.others,co2.residential)
test.all<-c("co2.cat.fuel.bio","co2.cat.fuel.gas","co2.cat.fuel.coal","co2.cat.fuel.oil")
test.plot<-rowSums (dat[,test.all,drop=F], na.rm = FALSE)
dat<-cbind(dat,test.plot)

output.veg <- c("evergreen", "decid", "mixfrst", "shrb", "savan", "crop", "grass", "others") #"peat" is replaced by "others" in Jena VPRM preproc.
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: output.veg",output.veg,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: fluxmod ",fluxmod,"\n")
  if (fluxmod == "GSB") {
      output.veg <- c("frst", "shrb", "crop")#, "wetl")
   }
   if (fluxmod != "GSB"&(landcov == "GLCC"|landcov == "SYNMAP"|landcov == "SYNMAP.VPRM8"))
      output.veg <- c("evergreen", "decid", "mixfrst", "shrb", "savan", "crop", "grass", "peat") #"peat" is replaced by "others" in Jena VPRM preproc.
   if (fluxmod != "GSB"&(landcov == "DVN"))
      output.veg <- c("evergreenA", "evergreenB", "evergreenC", "evergreenD", "decid", "mixfrst", "shrb", "savan", "crop", "grass", "peat")
output.veg <- c("evergreen", "decid", "mixfrst", "shrb", "savan", "crop", "grass", "others") #"peat" is replaced by "others" in Jena VPRM preproc.

#calculate CO2 from vegetation
resp.all<-rowSums (dat[,paste("resp",output.veg,sep=""),drop=F], na.rm = FALSE)
gee.all<-rowSums (dat[,paste("gee",output.veg,sep=""),drop=F], na.rm = FALSE)
infl.all<-rowSums (dat[,paste("infl",output.veg,sep=""),drop=F], na.rm = FALSE)#+dat[,"inflwater"]
co2.stilt<-resp.all+gee.all+dat[,"co2ini"]+dat[,"co2.cat.fuel.all"]
co2.bio<-resp.all+gee.all
co2.bio.gee<-gee.all
co2.bio.resp<-resp.all

co2.total<-co2.stilt

co2.fuel<-co2.cat.fuel.all
co2.fuel.coal<-co2.cat.fuel.coal
co2.fuel.gas<-co2.cat.fuel.gas
co2.fuel.oil<-co2.cat.fuel.oil
co2.fuel.bio<-co2.cat.fuel.bio
co2.fuel.waste<-co2.cat.fuel.waste
co2.background<-dat[,"co2ini"]

co2.ini<-dat[,"co2ini"]

co2.nee.offline<-dat[,"n_offline"]
co2.gee.offline<-dat[,"g_offline"]
co2.resp.offline<-dat[,"r_offline"]

tracer<-"co"

pars<-matrix(NA, ncol=3, nrow=lengths(dimnames(dat)[2]))
colnames(pars)<-c("trac", "cats", "fuels")
for(i in 1:lengths(dimnames(dat)[2])){
  fls<-strsplit(dimnames(dat)[[2]][i], split=".", fixed=T) #fls[[1]][3] 
  pars[i,]<-fls[[1]][1:3]
}
ucats<-unique(pars[,"cats"])  #length: 22
ufs<-unique(pars[,"fuels"])   #length: 13
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: ucats ",ucats,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: ufs ",ufs,"\n")

selco<-pars[(pars[,1]==tracer & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
co.cat.fuel.all<-rowSums (dat[,paste(selco[,1],selco[,2],selco[,3],sep="."),drop=F], na.rm = FALSE)

selcobio<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="bio" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcogas<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="gas" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcocoal<-pars[(pars[,1]==tracer & substring(pars[,3],1,4)=="coal" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcooil<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="oil" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcowaste<-pars[(pars[,1]==tracer & substring(pars[,3],1,11)=="solid_waste" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

co.cat.fuel.all<-rowSums (dat[,paste(selco[,1],selco[,2],selco[,3],sep="."),drop=F], na.rm = FALSE)
co.cat.fuel.bio<-rowSums (dat[,paste(selcobio[,1],selcobio[,2],selcobio[,3],sep="."),drop=F], na.rm = FALSE)
co.cat.fuel.gas<-rowSums (dat[,paste(selcogas[,1],selcogas[,2],selcogas[,3],sep="."),drop=F], na.rm = FALSE)
co.cat.fuel.coal<-rowSums (dat[,paste(selcocoal[,1],selcocoal[,2],selcocoal[,3],sep="."),drop=F], na.rm = FALSE)
co.cat.fuel.oil<-rowSums (dat[,paste(selcooil[,1],selcooil[,2],selcooil[,3],sep="."),drop=F], na.rm = FALSE)
co.cat.fuel.waste<-rowSums (dat[,paste(selcowaste[,1],selcowaste[,2],selcowaste[,3],sep="."),drop=F], na.rm = FALSE)

selcoenergy<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a1a","1a1bcr")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcotransport<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a3b","1a3ce","1a3a+1c1","1a3d+1c2")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcoindustry<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a2+6cd","2a","2befg+3","2c")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcoothers<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1b2abc","7a","4f")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selcoresident<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a4")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

co.energy<-rowSums (dat[,paste(selcoenergy[,1],selcoenergy[,2],selcoenergy[,3],sep="."),drop=F], na.rm = FALSE)
co.industry<-rowSums (dat[,paste(selcoindustry[,1],selcoindustry[,2],selcoindustry[,3],sep="."),drop=F], na.rm = FALSE)
co.transport<-rowSums (dat[,paste(selcotransport[,1],selcotransport[,2],selcotransport[,3],sep="."),drop=F], na.rm = FALSE)
co.others<-rowSums (dat[,paste(selcoothers[,1],selcoothers[,2],selcoothers[,3],sep="."),drop=F], na.rm = FALSE)
co.residential<-rowSums (dat[,paste(selcoresident[,1],selcoresident[,2],selcoresident[,3],sep="."),drop=F], na.rm = FALSE)

dat<-cbind(dat,co.cat.fuel.all,co.cat.fuel.bio,co.cat.fuel.gas,co.cat.fuel.coal,co.cat.fuel.oil,co.cat.fuel.waste,co.energy,co.transport,co.industry,co.others,co.residential)
test.all<-c("co.cat.fuel.bio","co.cat.fuel.gas","co.cat.fuel.coal","co.cat.fuel.oil")
test.plot<-rowSums (dat[,test.all,drop=F], na.rm = FALSE)
dat<-cbind(dat,test.plot)

co.stilt<-dat[,"coini"]+dat[,"co.cat.fuel.all"]

co.total<-co.stilt

co.fuel<-co.cat.fuel.all
co.fuel.coal<-co.cat.fuel.coal
co.fuel.gas<-co.cat.fuel.gas
co.fuel.oil<-co.cat.fuel.oil
co.fuel.bio<-co.cat.fuel.bio
co.fuel.waste<-co.cat.fuel.waste
co.background<-dat[,"coini"]

co.ini<-dat[,"coini"]

tracer<-"ch4"

pars<-matrix(NA, ncol=3, nrow=lengths(dimnames(dat)[2]))
colnames(pars)<-c("trac", "cats", "fuels")
for(i in 1:lengths(dimnames(dat)[2])){
  fls<-strsplit(dimnames(dat)[[2]][i], split=".", fixed=T) #fls[[1]][3] 
  pars[i,]<-fls[[1]][1:3]
}
ucats<-unique(pars[,"cats"])  #length: 22
ufs<-unique(pars[,"fuels"])   #length: 13
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: ucats ",ucats,"\n")
cat(format(Sys.time(), "%FT%T"),"DEBUG reform: ufs ",ufs,"\n")

selch4<-pars[(pars[,1]==tracer & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
ch4.cat.fuel.all<-rowSums (dat[,paste(selch4[,1],selch4[,2],selch4[,3],sep="."),drop=F], na.rm = FALSE)

selch4bio<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="bio" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4gas<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="gas" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4coal<-pars[(pars[,1]==tracer & substring(pars[,3],1,4)=="coal" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4oil<-pars[(pars[,1]==tracer & substring(pars[,3],1,3)=="oil" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4waste<-pars[(pars[,1]==tracer & substring(pars[,3],1,11)=="solid_waste" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4others<-pars[(pars[,1]==tracer & substring(pars[,3],1,6)=="others" & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

ch4.cat.fuel.all<-rowSums (dat[,paste(selch4[,1],selch4[,2],selch4[,3],sep="."),drop=F], na.rm = FALSE)
ch4.cat.fuel.bio<-rowSums (dat[,paste(selch4bio[,1],selch4bio[,2],selch4bio[,3],sep="."),drop=F], na.rm = FALSE)
ch4.cat.fuel.gas<-rowSums (dat[,paste(selch4gas[,1],selch4gas[,2],selch4gas[,3],sep="."),drop=F], na.rm = FALSE)
ch4.cat.fuel.coal<-rowSums (dat[,paste(selch4coal[,1],selch4coal[,2],selch4coal[,3],sep="."),drop=F], na.rm = FALSE)
ch4.cat.fuel.oil<-rowSums (dat[,paste(selch4oil[,1],selch4oil[,2],selch4oil[,3],sep="."),drop=F], na.rm = FALSE)
ch4.cat.fuel.waste<-rowSums (dat[,paste(selch4waste[,1],selch4waste[,2],selch4waste[,3],sep="."),drop=F], na.rm = FALSE)
ch4.cat.fuel.others<-rowSums (dat[,paste(selch4others[,1],selch4others[,2],selch4others[,3],sep="."),drop=F], na.rm = FALSE)

#selch4energy<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a1a")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
#selch4transport<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a3b","1a3ce","1a3a+1c1","1a3d+1c2")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
#selch4industry<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a2+6cd","2a","2befg+3","2c")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
#selch4others<-pars[(pars[,1]==tracer & (pars[,2] %in% c(,"1a1bcr","1b2abc","7a")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
#selch4resident<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a4")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
#selch4agri<-pars[(pars[,1]==tracer & (pars[,2] %in% c("4a","4b","4c","4d","4f")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
#selch4waste<-pars[(pars[,1]==tracer & (pars[,2] %in% c("6a","6b")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

selch4energy<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a1a","1a1bcr","1b1","1b2b")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4transport<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a3b","1a3ce","1a3a+1c1","1a3d+1c2")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4industry<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a2+6cd","2befg+3","2c")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4resident<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1a4")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4agri<-pars[(pars[,1]==tracer & (pars[,2] %in% c("4a","4b","4c","4f")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]
selch4waste<-pars[(pars[,1]==tracer & (pars[,2] %in% c("6a","6b")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

selch4others<-pars[(pars[,1]==tracer & (pars[,2] %in% c("1b2ac","7a")) & substring(pars[,3],nchar(pars[,3])-2,nchar(pars[,3]))!="ffm" & !is.na(pars[,2])),]

ch4.energy<-rowSums (dat[,paste(selch4energy[,1],selch4energy[,2],selch4energy[,3],sep="."),drop=F], na.rm = FALSE)
ch4.industry<-rowSums (dat[,paste(selch4industry[,1],selch4industry[,2],selch4industry[,3],sep="."),drop=F], na.rm = FALSE)
ch4.transport<-rowSums (dat[,paste(selch4transport[,1],selch4transport[,2],selch4transport[,3],sep="."),drop=F], na.rm = FALSE)
ch4.others<-rowSums (dat[,paste(selch4others[,1],selch4others[,2],selch4others[,3],sep="."),drop=F], na.rm = FALSE)
ch4.residential<-rowSums (dat[,paste(selch4resident[,1],selch4resident[,2],selch4resident[,3],sep="."),drop=F], na.rm = FALSE)
ch4.agri<-rowSums (dat[,paste(selch4agri[,1],selch4agri[,2],selch4agri[,3],sep="."),drop=F], na.rm = FALSE)
ch4.waste<-rowSums (dat[,paste(selch4waste[,1],selch4waste[,2],selch4waste[,3],sep="."),drop=F], na.rm = FALSE)

ch4.wetland<-dat[,"ch4wet"]
ch4.soil<-dat[,"ch4soil"]
ch4.uptake<-dat[,"ch4uptake"]
ch4.peatland<-dat[,"ch4peat"]
ch4.geo<-dat[,"ch4geo"]
ch4.fire<-dat[,"ch4fire"]
ch4.ocean<-dat[,"ch4ocean"]
ch4.lakes<-dat[,"ch4lakes"]
ch4.check<-dat[,"ch4total"]
ch4.nat<-ch4.wetland+ch4.soil+ch4.uptake+ch4.peatland+ch4.geo+ch4.fire+ch4.ocean+ch4.lakes

#ch4.edgar6<-dat[,"ch4edg6"]
ch4.edgar7<-dat[,"ch4edg7"]

#dat<-cbind(dat,ch4.cat.fuel.all,ch4.cat.fuel.bio,ch4.cat.fuel.gas,ch4.cat.fuel.coal,ch4.cat.fuel.oil,ch4.cat.fuel.waste,ch4.energy,ch4.transport,ch4.industry,ch4.others,ch4.residential)
dat<-cbind(dat,ch4.cat.fuel.all,ch4.cat.fuel.bio,ch4.cat.fuel.gas,ch4.cat.fuel.coal,ch4.cat.fuel.oil,ch4.cat.fuel.waste,ch4.energy,ch4.transport,ch4.industry,ch4.others,ch4.residential,ch4.agri,ch4.waste,ch4.wetland,ch4.soil,ch4.uptake,ch4.peatland,ch4.geo,ch4.fire,ch4.ocean,ch4.lakes,ch4.check,ch4.edgar7)
test.all<-c("ch4.cat.fuel.bio","ch4.cat.fuel.gas","ch4.cat.fuel.coal","ch4.cat.fuel.oil")
test.plot<-rowSums (dat[,test.all,drop=F], na.rm = FALSE)
dat<-cbind(dat,test.plot)

#ch4.stilt<-dat[,"ch4ini"]+dat[,"ch4.cat.fuel.all"]+ch4.nat
ch4.stilt<-dat[,"ch4ini"]+ch4.energy+ch4.transport+ch4.industry+ch4.others+ch4.residential+ch4.agri+ch4.waste+ch4.nat

ch4.total<-ch4.stilt

ch4.fuel<-ch4.cat.fuel.all
ch4.fuel.coal<-ch4.cat.fuel.coal
ch4.fuel.gas<-ch4.cat.fuel.gas
ch4.fuel.oil<-ch4.cat.fuel.oil
ch4.fuel.bio<-ch4.cat.fuel.bio
ch4.fuel.waste<-ch4.cat.fuel.waste
ch4.fuel.others<-ch4.cat.fuel.others
ch4.background<-dat[,"ch4ini"]

ch4.ini<-dat[,"ch4ini"]

dat2<-cbind(dat2,co2.stilt,co2.bio,co2.bio.gee,co2.bio.resp,co2.fuel,co2.fuel.oil,co2.fuel.coal,co2.fuel.gas,co2.fuel.bio,co2.fuel.waste,co2.energy,co2.transport,co2.industry,co2.others,co2.residential,co2.background,co.stilt,co.fuel,co.fuel.oil,co.fuel.coal,co.fuel.gas,co.fuel.bio,co.fuel.waste,co.energy,co.transport,co.industry,co.others,co.residential,co.background,ch4.stilt,ch4.fuel,ch4.fuel.oil,ch4.fuel.coal,ch4.fuel.gas,ch4.fuel.bio,ch4.fuel.waste,ch4.fuel.others,ch4.energy,ch4.transport,ch4.industry,ch4.others,ch4.residential,ch4.agri,ch4.waste,ch4.background,rn,rn.noah,rn.era,rn.const,rn.noah2,rn.era5,rn.noah2_m,rn.era5_m,rn.background,co2.nee.offline,co2.gee.offline,co2.resp.offline,ch4.wetland,ch4.soil,ch4.uptake,ch4.peatland,ch4.geo,ch4.fire,ch4.ocean,ch4.lakes,ch4.check,ch4.edgar7)

# write results incl. wind information - if exists
if ("ubar" %in% colnames(dat)) {
  cat(format(Sys.time(), "%FT%T"),"DEBUG reform: wind info included in stiltresults..._wind.csv","\n")
  wind.u<-dat[,"ubar"]
  wind.v<-dat[,"vbar"]
  wind.w<-dat[,"wbar"]
  wind.dir<-dat[,"wind.dir"]
  dat3<-cbind(dat2,wind.u,wind.v,wind.w,wind.dir)
  cat(format(Sys.time(), "%FT%T"),"DEBUG reform wind: colnames(dat3) ",colnames(dat3),"\n")
  write.table(dat3, file=paste(pathResults,"/",stiltresultname,".csv",sep=""), na="", row.names=F, quote=F)
} else {
  cat(format(Sys.time(), "%FT%T"),"DEBUG reform: colnames(dat2) ",colnames(dat2),"\n")
  write.table(dat2, file=paste(pathResults,"/",stiltresultname,".csv",sep=""), na="", row.names=F, quote=F)
}

