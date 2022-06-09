rm(list=ls()) 
cat("\014") 
################################################################################################
################################################################################################
######################## configurar parametros #################################################
sy <- 2000
ey <- 2015
Warea <- "Modelo La Paz y El Alto V2.12"
scen <- "Reference"
ts <- 12 #Este script no funciona en modelos diarios que incluyen años bisiestos
#año de inicio para calculo de GOF, cualquiera pero minimo el año base + 1
yearINI=2001

################################################################################################
################################################################################################
################################################################################################
################################################################################################
dir=paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/Results ",Warea)
setwd(dir)
library(reshape2)
library(lubridate)
library(hydroGOF)
library(RDCOMClient)
library(DT)
library(deSolve)
library(ggplot2)
library(hydroTSM)
library(dplyr)
library(tidyr)

dates=c(ymd(as.Date(paste0(yearINI,"-01-01"))),ymd(as.Date(paste0(ey,"-12-31"))))
multiplot = function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  # Multiple plot function
  #
  # ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
  # - cols:   Number of columns in layout
  # - layout: A matrix specifying the layout. If present, 'cols' is ignored.
  #
  # If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
  # then plot 1 will go in the upper left, 2 will go in the upper right, and
  # 3 will go all the way across the bottom.
  #
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots = c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout = matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx = as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
start = Sys.time()

#procesar GOF
################################################################################################

#genera archivo GOF en un rango de fechas
errorEvaluar=c(
  1, #1.	me, Mean Error
  2, #2.	mae, Mean Absolute Error
  # 3, #3.	mse, Mean Squared Error
  # 4, #4.	rmse, Root Mean Square Error
  5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
  6, #6.	PBIAS, Percent Bias
  # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
  # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
  9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
  10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
  # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
  12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
  13,  #13.	md, Modified Index of Agreement 
  # 14,#14.	rd, Relative Index of Agreement
  # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
  # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
  17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
  18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
  19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
  20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
) 
names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
              "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
              "KGE" ,    "VE" ) 
names_errorg=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS", "RSR"   ,  "rSD"  ,   "NSE" ,   
               "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
               "KGE" ,    "VE" ) 
#names_error[errorEvaluar]

names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 

metricsALL=NULL

listResults=list.files(pattern ="ResultsWB-")
listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
listResults=gsub(".csv","",listResults,fixed = TRUE)
listResults=unique(as.numeric(listResults))
listResults

runs <- length(listResults)

for (i in 1:listResults){
  setwd(dir)
  Carpeta_Out=paste0(i,"_Graficas")
  dir.create(Carpeta_Out,showWarnings=F)
  dir_outg = paste(c(dir,"\\",Carpeta_Out),collapse="")
  
  ########
  #i=1
  RUNID=i
  
  file=read.csv(paste0("ResultsWB-",RUNID,".csv"), stringsAsFactors=F, check.names=F)
  
  file$Dates=ymd(file$Dates)
  file$YearMonth=year(file$Dates)*100+month(file$Dates)
  file$Month=month(file$Dates)
  
  fileOrg=file
  
  filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]
  days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
  filesub=merge(filesub,days,by="Time step")
  filesub1=filesub
  
  filesub1$Observed=filesub1$Observed/filesub1$Days/86400
  filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400
  p <- ggplot(filesub1, aes(x=Dates, y=Modeled)) + 
    geom_line(color="blue",size=0.2)+
    geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
    facet_wrap( ~ Gauge, scales = "free") +
    ylab(paste0("[m3/s]"))+
    ggtitle(paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)"))
  p
  
  setwd(dir_outg)
  plotpath = paste0("Streamflow-",RUNID,".jpg") #creates a pdf path to produce a graphic of the span of records in the Data
  ggsave(plotpath,width =40 , height = 22,units = "cm")
  
  file=fileOrg
  uniqueGauges=sort(unique(file$Gauge))
  
  metricsAll=NULL
  
  for (t in 1:3){
    
    metrics=as.data.frame(matrix(nrow=length(uniqueGauges),ncol=(12+length(errorEvaluar)*2)))
    colnames(metrics) <- c("Gauge","Run ID",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Type","Period")
    
    metrics[,1]=uniqueGauges
    metrics[,2]=i
    
    for (g in 1:length(uniqueGauges)){
      
      filesub=file[file$Gauge==uniqueGauges[g],]
      total=nrow(filesub)
      filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
      r1=nrow(filesubt)
      DatesRegister=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
      metrics[g,"Period"]=DatesRegister
      
      filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
      n=round(nrow(filesubt)*0.7,0)
      total=nrow(filesubt)
      
      
      if (t==1){
        
        r1=nrow(filesubt)
        DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
        
        metrics$Type="All"
        
        filewb=filesub
        filewb=filewb[filewb$Dates>=as.Date(filesubt$Dates[1]), ]
        filewb=filewb[filewb$Dates<=as.Date(filesubt$Dates[nrow(filesubt)]), ]
        
      } else if (t==2) {
        
        filesubt=filesubt[1:n,]
        r1=nrow(filesubt)
        
        filewb=filesub
        filewb=filewb[filewb$Dates>=as.Date(filesubt$Dates[1]), ]
        filewb=filewb[filewb$Dates<=as.Date(filesubt$Dates[nrow(filesubt)]), ]
        
        filesub=filesub[filesub$Dates>=as.Date(filesubt$Dates[1]), ]
        total=nrow(filesub[filesub$Dates<=as.Date(filesubt$Dates[nrow(filesubt)]), ])
        
        DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
        
        metrics$Type="Calibration (70%)"
        
      } else {
        
        filesubt=filesubt[(n+1):nrow(filesubt),]
        r1=nrow(filesubt)
        
        filewb=filesub
        filewb=filewb[filewb$Dates>=as.Date(filesubt$Dates[1]), ]
        filewb=filewb[filewb$Dates<=as.Date(filesubt$Dates[nrow(filesubt)]), ]
        
        filesub=filesub[filesub$Dates>=as.Date(filesubt$Dates[1]), ]
        total=nrow(filesub[filesub$Dates<=as.Date(filesubt$Dates[nrow(filesubt)]), ])
        
        DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
        
        metrics$Type="Validation (30%)"
        
      }
      
      
      
      filesub=filewb
      Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      Filemonthly$N=1
      Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
      Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
      Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
      Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
      Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
      metrics[g,(7+length(errorEvaluar)*2):(7+2*length(errorEvaluar)+3)]=Filemonthly[1,7:10]
      
      filesub=filesubt
      r=nrow(filesub)
      modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
      observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
      
      filesub$Modeled[which(filesub$Modeled ==0)]=NA
      filesub$Observed[which(filesub$Observed ==0)]=NA
      filesub=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
      modeledlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Modeled,10)
      observedlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Observed,10)
      
      if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
        error=gof(modeled,observed,na.rm=TRUE)
        metrics[g,3:(2+length(errorEvaluar))]=round(error[errorEvaluar],3)
        errorLOG=gof(modeledlog,observedlog,digits=5,na.rm=TRUE)
        metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=round(errorLOG[errorEvaluar],3)
      } else {
        metrics[g,3:(2+length(errorEvaluar))]=NA
        metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=NA
      }
      metrics$PeriodGOF[g]=DatesRegister
      metrics[g,2+length(errorEvaluar)*2+1]=min(na.exclude(filesub$Observed))/min( na.exclude(filesub$Modeled))*100   
      metrics[g,2+length(errorEvaluar)*2+2]=mean(na.exclude(filesub$Observed))/mean( na.exclude(filesub$Modeled))*100   
      metrics[g,2+length(errorEvaluar)*2+3]=max(na.exclude(filesub$Observed))/max( na.exclude(filesub$Modeled))*100   
      
    }
    
    metricsAll=rbind(metricsAll,metrics)
    
    
  }
  
  metrics=metricsAll
  
  metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")]=round(metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")],2)
  cols <- c("Type","Period","Gauge","Run ID","PeriodGOF",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %")
  metrics=metrics[,cols]
  setwd(dir_outg)
  write.csv(metrics,paste0("SummaryGOF_",paste(dates,collapse ="_"),".csv"),row.names=F) 
  
  
}

################################################################################################
runTimeGOF=difftime(Sys.time(),start)
runTimeGOF

#procesaar graficas y GOF
###############################################################################################
metrics <- NULL

for (f in 1:listResults){

setwd(dir)
Carpeta_Out=paste0(f,"_Graficas")
dir.create(Carpeta_Out,showWarnings=F)

dir_file=paste(c(dir,"\\",Carpeta_Out),collapse="")
year1 = yearINI
year2= ey

LEAP=FALSE

RUNID=f

file=read.csv(paste0("ResultsWB-",RUNID,".csv"), stringsAsFactors=F, check.names=F)
file$Dates=ymd(file$Dates)
file$YearMonth=year(file$Dates)*100+month(file$Dates)
file$Month=month(file$Dates)
filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]

days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
filesub=merge(filesub,days,by="Time step")

filesub1=filesub
filesub1$Observed=filesub1$Observed/filesub1$Days/86400
filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400

obsFile=filesub1[,c("Dates","Gauge","Observed")]
simFile=filesub1[,c("Dates","Gauge","Modeled")]
obsFile = obsFile %>% pivot_wider(names_from = Gauge, values_from = Observed)
simFile = simFile %>% pivot_wider(names_from = Gauge, values_from = Modeled)
obsFile=obsFile[order(obsFile$Dates),]
simFile=simFile[order(simFile$Dates),]
#obsFile = obsFile[,-1]
#simFile = simFile[,-1]

namesFile=colnames(simFile)[2:ncol(simFile)]
#names <- read.csv(namesFile, stringsAsFactors=F, check.names=T)
names=namesFile

GofGrafica=names_errorg[errorEvaluar]
GofTabla=names_error[errorEvaluar]


obsv=as.data.frame(obsFile[,-1])
simv=as.data.frame(simFile[,-1])

setwd(dir_file)
Carpeta_Out="SimObs_Todos"
dir.create(Carpeta_Out,showWarnings=F)
dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
setwd(dir_file1)


filesub=filesub1[,c("Dates","Gauge","Modeled","Observed")]
filesub1=filesub
colnames(filesub1)[2]=c("Gauge")
colnames(filesub1)[1]=c("Fecha")
filesub1=filesub1[order(filesub1$Fecha,filesub1$Gauge),]
p <- ggplot(filesub1, aes(x=Fecha, y=Modeled)) + 
  geom_line(color="blue",size=0.2)+
  geom_line(aes(x=Fecha, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
  facet_wrap( ~ Gauge, scales = "free") +
  ylab(paste0("[m3/s]"))+
  ggtitle(paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)"))
p
ggsave("Series.jpg",width =40 , height = 22,units = "cm")


filesub1$monthyear=floor_date(filesub1$Fecha, "month")
filesub1 <- filesub1[order(filesub1$Gauge,filesub1$Fecha),]

if (ts==12){
  filesub1$month=seq(1:12)
} else if (ts==365){
  filesub1$day=seq(1:365)
  df_d=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, day=df$day),mean, na.rm=TRUE)
  df_d=df_d[order(df_d$Gauge,df_d$day),]
  df_d$Fecha = seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "day")
  #dfsim_d$date = format(dfsim_d$date, "%b %d")
  write.csv(df_d,"MediosDiariosLongFormat.csv",row.names=FALSE,na="")

  filesub1=df_d
  p <- ggplot(filesub1, aes(x=Fecha, y=Modeled)) + 
    geom_line(color="blue",size=0.2)+
    geom_line(aes(x=Fecha, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
    facet_wrap( ~ Gauge, scales = "free") +
    ylab(paste0("[m3/s]"))+
    ggtitle(paste0("Medio Diario Multianual: ","Modelado (azul) vs Observado (rojo)"))
  p= p + scale_x_date(date_labels = "%b/%d")
  p
  ggsave("DiarioMultianual.jpg",width =40 , height = 22,units = "cm")
  
}

write.csv(filesub1,"DatosLongFormat.csv",row.names=FALSE,na="")

df=filesub1
df_m=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, monthyear=df$monthyear),mean, na.rm=TRUE)
df_m$month <- month(df_m$monthyear)
df_m=aggregate(df_m[,c("Modeled","Observed")],list(Gauge=df_m$Gauge, month=df_m$month),mean, na.rm=TRUE)
df_m=df_m[order(df_m$Gauge,df_m$month),]
df_m$Fecha = seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
write.csv(df_m,"MediosMensualesLongFormat.csv",row.names=FALSE,na="")


filesub1=df_m
p <- ggplot(filesub1, aes(x=Fecha, y=Modeled)) + 
  geom_line(color="blue",size=0.2)+
  geom_line(aes(x=Fecha, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
  facet_wrap( ~ Gauge, scales = "free") +
  ylab(paste0("[m3/s]"))+
  ggtitle(paste0("Medio Mensual Multianual: ","Modelado (azul) vs Observado (rojo)"))
p= p + scale_x_date(date_labels = "%B")
p 
ggsave("MensualMultianual.jpg",width =40 , height = 22,units = "cm")


for (i in 1:length(names)){
  
  name <- names[i]
  
  if (length(which(is.na(obsv[,i])==TRUE))<length(obsv[,i])){
    obs = zoo(obsv[,i],as.Date(obsFile$Dates))
    sim = zoo(simv[,i],as.Date(simFile$Dates))
    sim <- window(sim, start=as.Date(paste0(yearINI,"-01-01")))
    obs <- window(obs, start=as.Date(paste0(yearINI,"-01-01")))
    
    if (ts==12){
      setwd(dir_file)
      Carpeta_Out="SimObs_ma"
      dir.create(Carpeta_Out,showWarnings=F)
      dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
      setwd(dir_file1)
      png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
      ggof(sim=sim, obs=obs, ftype="ma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name,xlab=c("Fecha"), ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
      #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
      dev.off()
    } else if (ts==365){
      setwd(dir_file)
      Carpeta_Out="SimObs_dma"
      dir.create(Carpeta_Out,showWarnings=F)
      dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
      setwd(dir_file1)
      png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
      ggof(sim=sim, obs=obs, ftype="dma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name,xlab=c("Fecha"), ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
      #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
      dev.off()
      
      setwd(dir_file)
      Carpeta_Out="SimObs_temporadas"
      dir.create(Carpeta_Out,showWarnings=F)
      dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
      setwd(dir_file1)
      png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
      ggof(sim=sim, obs=obs, ftype="seasonal", season.names=c("", "", "", ""),na.rm=TRUE,FUN=mean, leg.cex=1.2, pch = c(20, 18),main = name,xlab=c("Fecha"), ylab=c("Q[m3/s]"))
      dev.off()
      #lwd = c(1, 1),lty = c(1, 1),  pch = c(19, 19),,na.rm=TRUE,,  gofs=GofGrafica
      
    }
    
    if (ts==365){
      df <- data.frame(date = as.Date(simFile$Dates), Caudal = simv[,i])
      df$monthyear=floor_date(df$date, "month")
      df$day <- seq(1:365)
      df_d=as.data.frame(df %>%
                           group_by(day) %>%
                           summarize(mean = mean(Caudal,na.rm = TRUE)))
      df_d$date = seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "day")
      #dfsim_d$date = format(dfsim_d$date, "%b %d")
      
      dfsim_d=df_d
      df <- data.frame(date = as.Date(obsFile$Dates), Caudal = obsv[,i])
      df$monthyear=floor_date(df$date, "month")
      df$day <- seq(1:365)
      df_d=as.data.frame(df %>%
                           group_by(day) %>%
                           summarize(mean = mean(Caudal,na.rm = TRUE)))
      df_d$date = seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "day")
      #dfsim_d$date = format(dfsim_d$date, "%b %d")
      dfobs_d=df_d
      
      #grafica medios diarios multianuales
      obs = zoo(dfobs_d[,2],dfobs_d[,3])
      sim = zoo(dfsim_d[,2],dfsim_d[,3])
      
      setwd(dir_file)
      Carpeta_Out="SimObs_diariomultianual"
      dir.create(Carpeta_Out,showWarnings=F)
      dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
      setwd(dir_file1)
      png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
      ggof(sim=sim, obs=obs, lab.fmt="%b %d", ftype="o",tick.tstep = "days", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- Medios diarios multianuales"),xlab=c("Fecha"), ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
      dev.off()
      
    }
    
    #sim
    df <- data.frame(date = as.Date(simFile$Dates), Caudal = simv[,i])
    df$monthyear=floor_date(df$date, "month")
    #tail(df)
    
    df_m=as.data.frame(df %>%
                         group_by(monthyear) %>%
                         summarize(mean = mean(Caudal,na.rm = TRUE)))
    df_m$month <- month(df_m$monthyear)
    df_m=as.data.frame(df_m %>%
                         group_by(month) %>%
                         summarize(mean = mean(mean,na.rm = TRUE)))
    df_m$date = seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
    dfsim_m=df_m
    
    #obs
    df <- data.frame(date = as.Date(obsFile$Dates), Caudal = obsv[,i])
    df$monthyear=floor_date(df$date, "month")
    #tail(df)
    
    df_m=as.data.frame(df %>%
                         group_by(monthyear) %>%
                         summarize(mean = mean(Caudal,na.rm = TRUE)))
    df_m$month <- month(df_m$monthyear)
    df_m=as.data.frame(df_m %>%
                         group_by(month) %>%
                         summarize(mean = mean(mean,na.rm = TRUE)))
    df_m$date = seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
    dfobs_m=df_m
    
    #grafica medios mensuales multianuales
    obs = zoo(dfobs_m[,2],dfobs_m[,3])
    sim = zoo(dfsim_m[,2],dfsim_m[,3])
    
    setwd(dir_file)
    Carpeta_Out="SimObs_mensualmultianual"
    dir.create(Carpeta_Out,showWarnings=F)
    dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
    setwd(dir_file1)
    png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
    ggof(sim=sim, obs=obs, lab.fmt="%b", ftype="o",tick.tstep = "months", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- Medios mensuales multianuales"),xlab=c("Fecha"), ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
    dev.off()
    
    #residuales
    obs = zoo(obsv[,i],as.Date(obsFile$Dates))
    sim = zoo(simv[,i],as.Date(simFile$Dates))
    sim <- window(sim, start=as.Date(paste0(yearINI,"-01-01")))
    obs <- window(obs, start=as.Date(paste0(yearINI,"-01-01")))
    
    setwd(dir_file)
    Carpeta_Out="Sim"
    dir.create(Carpeta_Out,showWarnings=F)
    dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
    setwd(dir_file1)
    png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
    hydroplot(sim, FUN=mean,var.unit="m3/s",main=paste0(name," Simu"),xlab="",na.rm=TRUE)
    dev.off()
    
    setwd(dir_file)
    Carpeta_Out="Obs"
    dir.create(Carpeta_Out,showWarnings=F)
    dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
    setwd(dir_file1)
    png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
    hydroplot(obs, FUN=mean,var.unit="m3/s",main=paste0(name," Obs"),xlab="",na.rm=TRUE)
    dev.off()
    
    
    r <- sim-obs
    smry(r)
    setwd(dir_file)
    Carpeta_Out="SimObs_residuales"
    dir.create(Carpeta_Out,showWarnings=F)
    dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
    setwd(dir_file1)
    png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
    hydroplot(r, FUN=mean,var.unit="m3/s",main=paste0(name," Residuales"),xlab="",na.rm=TRUE)
    dev.off()
    
    #metricas en tabla
    
    
    if (ts==365){
      m <- gof(sim=sim, obs=obs)
      m <- as.data.frame(m)
      m$Metricas <- rownames(m)
      m$Estacion <- name
      m$Tipo <- "Diario"
      metrics=rbind(metrics,m)
      
      sim = daily2monthly.zoo(sim, FUN = mean)
      obs = daily2monthly.zoo(obs, FUN = mean)
      m <- gof(sim=sim, obs=obs)
      m <- as.data.frame(m)
      m$Metricas <- rownames(m)
      m$Estacion <- name
      m$Tipo <- "Mensual"
      metrics=rbind(metrics,m)
      
      sim = monthly2annual(sim, FUN = mean)
      obs = monthly2annual(obs, FUN = mean)
      m <- gof(sim=sim, obs=obs)
      m <- as.data.frame(m)
      m$Metricas <- rownames(m)
      m$Estacion <- name
      m$Tipo <- "Anual"
      metrics=rbind(metrics,m)  
      
      m <- gof(sim=dfsim_d[,2], obs=dfobs_d[,2])
      m <- as.data.frame(m)
      m$Metricas <- rownames(m)
      m$Estacion <- name
      m$Tipo <- "Diario multianual"
      metrics=rbind(metrics,m)
    }
    
    if (ts==12){
      m <- gof(sim=sim, obs=obs)
      m <- as.data.frame(m)
      m$Metricas <- rownames(m)
      m$Estacion <- name
      m$Tipo <- "Mensual"
      metrics=rbind(metrics,m)
      
      sim = monthly2annual(sim, FUN = mean)
      obs = monthly2annual(obs, FUN = mean)
      m <- gof(sim=sim, obs=obs)
      m <- as.data.frame(m)
      m$Metricas <- rownames(m)
      m$Estacion <- name
      m$Tipo <- "Anual"
      metrics=rbind(metrics,m)  
      
    } 
   
    m <- gof(sim=dfsim_m[,2], obs=dfobs_m[,2])
    m <- as.data.frame(m)
    m$Metricas <- rownames(m)
    m$Estacion <- name
    m$Tipo <- "mensual multianual"
    metrics=rbind(metrics,m)
  }

  }
metrics$ID=f
}

setwd(dir_file)
metricas <- subset(metrics, Metricas %in% GofTabla)
write.csv(metricas, file="MetricasGGOF.csv",row.names = FALSE)

################################################################################################
runTimeGOF2=difftime(Sys.time(),start)