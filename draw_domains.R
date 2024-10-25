setwd("D:\\projects\\new_cas\\Cas9d\\专利\\素材")
library(ggplot2)
library("ggrepel")
library(cowplot)
if (FALSE) {
  cas12i1<-data.frame(index=c(23,181,278,473,636,685,845,888,942,1072,1093),label=c("WED","REC1","PI","REC1","WED","RuvC-I","REC2","BH","RuvC-II","Nuc","RuvC-III"))
  cas12i2<-data.frame(index=c(16,176,269,441,584,636,788,827,880,1072,1054),label=c("WED","REC1","PI","REC1","WED","RuvC-I","REC2","BH","RuvC-II","Nuc","RuvC-III"))
  YTGE_255<-data.frame(index=c(17,180,289,493,645,695,850,889,942,1072,1086),label=c("WED","REC1","PI","REC1","WED","RuvC-I","REC2","BH","RuvC-II","Nuc","RuvC-III"))
  YTGE_265<-data.frame(index=c(18,176,263,433,577,631,775,814,867,990,1022),label=c("WED","REC1","PI","REC1","WED","RuvC-I","REC2","BH","RuvC-II","Nuc","RuvC-III"))
  
  cas12o1<-data.frame(index=c(12,336,484,532,697,730,795,816,832,954),label=c("WED","REC1","WED","RuvC-I","REC2","BH","RuvC-II","Nuc","RuvC-III","Nuc"))
  cas12o2<-data.frame(index=c(22,358,511,565,723,764,818,853,874,984),label=c("WED","REC1","WED","RuvC-I","REC2","BH","RuvC-II","Nuc","RuvC-III","Nuc"))
  
  cas12b1<-data.frame(index=c(13,390,508,621,638,659,821,895,975,991,1129),label=c("WED","REC1","WED","RuvC-I","REC2","BH","REC2","RuvC-II","Nuc","RuvC-III","Nuc"))
  OgeuIscB1<-data.frame(index=c(55,86,123,161,199,297,375,430,496),label=c("PLMP","RuvC-I","BH","REC","RuvC-II","HNH","RuvC-III","WED","TI"))
  CasY8_3<-data.frame(index=c(54,85,110,127,162,263,341,366,426),label=c("PLMP","RuvC-I","BH","L1","RuvC-II","HNH","RuvC-III","L2","TI"))
  CasY8_2<-data.frame(index=c(48,89,114,133,164,268,343,372,404,442,463),label=c("PLMP","RuvC-I","BH","L1","RuvC-II","HNH","RuvC-III","L2","TI","NI","TI"))
  
}

SpCas9 <- data.frame(index=c(58,94,180,308,717,766,908,1099,1137,1224,1335,1368),label=c("RuvC-I","BH","REC1","REC2","REC1","RuvC-II","HNH","RuvC-III","WED","PI","Insertion","PI"))
SaCas9 <- data.frame(index=c(41,75,222,434,481,650,781,910,1053),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1001 <- data.frame(index=c(33,58,91,193,235,351,410,540,630),label=c("RuvC-I","BH","Linker","REC","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1002 <- data.frame(index=c(34,60,94,202,244,360,445,556,640),label=c("RuvC-I","BH","Linker","REC","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1003 <- data.frame(index=c(33,72,149,248,291,418,509,614,700),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1004 <- data.frame(index=c(36,75,174,275,318,437,541,654,747),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1005 <- data.frame(index=c(36,76,172,314,358,483,652,808,946),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1006 <- data.frame(index=c(45,84,161,260,303,422,522,627,713),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1007 <- data.frame(index=c(36,75,181,283,326,445,550,663,761),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1008 <- data.frame(index=c(36,75,174,275,318,437,541,654,747),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1009 <- data.frame(index=c(61,86,139,274,317,430,554,667,763),label=c("RuvC-I","BH","Linker","REC","RuvC-II","HNH","RuvC-III","WED","PI"))
YTGE_1010 <- data.frame(index=c(47,86,175,275,318,437,541,663,761),label=c("RuvC-I","BH","REC1","REC2","RuvC-II","HNH","RuvC-III","WED","PI"))

mycolors<-c("#8BF2B0","#8BF2B0","#8BF2B0","#ABDDFF","#FFFFFF","#F4F487","#E8C070","#E8C070","#C96D6D","#3054C6","#FFC0F6","#238779")
names(mycolors)<-c("RuvC-I","RuvC-II","RuvC-III","BH","Linker","REC1","REC2","REC","WED","HNH","PI","Insertion")
draw<-function(x,height){
  xmin<-c(1,x$index[-length(x$index)])
  xmax<-x$index
  data<-data.frame(xmin=xmin,xmax=xmax,ymin=0,ymax=height,label=x$label)
  p<-ggplot(data=data)+geom_rect(aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,fill=label),color="black",size=0.4)+
    geom_text_repel(aes(x=xmin+(xmax-xmin)/2, y=ymin+(ymax-ymin)/2,label=label),direction = "y",force_pull=5,point.padding = NA,point.size=NA)+coord_fixed()+
    geom_text(aes(x=xmax[length(xmax)],y=height/2,label=xmax[length(xmax)]),hjust=-1)+
    scale_x_continuous(limits = c(0,1400))+
    scale_fill_manual(breaks = data$label,values = mycolors[data$label])+
    theme_void()+
    theme(legend.position = "none")
  return(p)
}


ids<-c("SaCas9","SpCas9","YTGE_1001","YTGE_1002","YTGE_1003","YTGE_1004","YTGE_1005","YTGE_1006","YTGE_1007","YTGE_1008","YTGE_1009","YTGE_1010")

t<-list(SaCas9,SpCas9,YTGE_1001,YTGE_1002,YTGE_1003,YTGE_1004,YTGE_1005,YTGE_1006,YTGE_1007,YTGE_1008,YTGE_1009,YTGE_1010)
names(t)<-ids
for (i in ids) {
  data<-t[[i]]
  assign(paste0("p_",i),draw(data,height=35))
}

graphics.off()
pdf("merged_domains.pdf",width = 30,height = 14)
plot_grid(p_SaCas9,p_SpCas9,p_YTGE_1001,p_YTGE_1002,p_YTGE_1003,p_YTGE_1004,p_YTGE_1005,p_YTGE_1006,p_YTGE_1007,p_YTGE_1008,p_YTGE_1009,p_YTGE_1010, align = "h",axis = "lr", ncol = 1,labels = ids,vjust = 0.9,hjust=0)+theme(plot.margin = margin(1,0,1,1, "cm"))
dev.off()












