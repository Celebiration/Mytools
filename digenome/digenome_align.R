#!/usr/bin/Rscript
#setwd("D:\\projects\\杂项\\zhk_7_5_digenome_seq")
library(Biostrings)
Args<-commandArgs(trailingOnly=T)
input<-Args[1]
output<-Args[2]
#ref<-"AGGCAAGGCTGGCCAACCCATGG"
ref<-Args[3]
data<-read.csv(input,sep = "\t",stringsAsFactors = F,header = F)
names(data)<-c("PositionReads","forward_Reads","reverse_Depth","forward_Depth","reverse_Ratio","forward_Ratio","reverse_Cleavage","score","overhang","seq")
myfun<-function(seq,ref){
  strand<-"+"
  tmp<-pairwiseAlignment(DNAString(ref),DNAString(seq),type="global-local",gapOpening=7,gapExtension=5)
  tmp2<-pairwiseAlignment(DNAString(ref),reverseComplement(DNAString(seq)),type="global-local",gapOpening=7,gapExtension=5)
  if (score(tmp2) > score(tmp)) {
    tmp<-tmp2
	strand<-"-"
  }
  return(c(as.character(alignedPattern(tmp)),as.character(alignedSubject(tmp)),strand))
}
tmp<-t(as.data.frame(lapply(data$seq, myfun,ref)))
row.names(tmp)<-NULL
res<-data.frame(score=data$score,seq=tmp[,2],ref=tmp[,1],pos=data$PositionReads,overhang=data$overhang,strand=tmp[,3])
write.table(res,output,sep = "\t",row.names = F,quote = F)
