setwd("D:\\projects\\new_cas\\new_cas_analysis\\build_RuvC_tree")
library(Biostrings)
library(IRanges)
data<-readAAStringSet("synthesized.fa")
ls<-data.frame(id=names(data),length=width(data))

##合并positions
R1<-read.csv("synthesized.RuvC_I.positions.tsv",sep = "\t",stringsAsFactors = F,header = F)
R2<-read.csv("synthesized.RuvC_II.positions.tsv",sep = "\t",stringsAsFactors = F,header = F)
R3<-read.csv("synthesized.RuvC_III.positions.tsv",sep = "\t",stringsAsFactors = F,header = F)
Rall<-merge(R1,R2,by="V1",all=T)
Rall<-merge(Rall,R3,by="V1",all=T)
names(Rall)<-c("id","R1_pos","R2_pos","R3_pos")
write.table(Rall,"synthesized.merged_positions.tsv",sep = "\t",row.names = F)

##手动审查数据
##提取序列
data1<-read.csv("synthesized.merged_positions.tsv",sep = "\t",header = T,stringsAsFactors = F)
data1<-na.omit(data1)
#R1(-16,+30)
R1<-merge(data1[,c("id","R1_pos")],ls,by="id",all.x=T)
R1$V2<-R1$R1_pos-16
R1$V3<-R1$R1_pos+30
R1$V2[R1$V2<1]<-1
R1$V3[R1$V3>R1$length]<-R1$length[R1$V3>R1$length]
R1_seqs<-c()
for (i in 1:nrow(R1)) {
  id<-R1$id[i]
  start<-R1$V2[i]
  end<-R1$V3[i]
  R1_seqs<-c(R1_seqs,substr(data[id],start = start,stop = end))
}
R1_seqs<-data.frame(id=names(R1_seqs),R1_seqs)
row.names(R1_seqs)<-NULL
res<-AAStringSet(R1_seqs$R1_seqs)
names(res)<-R1_seqs$id
writeXStringSet(res,"synthesized.RuvC_I.seqs.10_25.fa")

#R2(-37,20)
R2<-merge(data1[,c("id","R2_pos")],ls,by="id",all.x=T)
R2$V2<-R2$R2_pos-37
R2$V3<-R2$R2_pos+20
R2$V2[R2$V2<1]<-1
R2$V3[R2$V3>R2$length]<-R2$length[R2$V3>R2$length]
R2_seqs<-c()
for (i in 1:nrow(R2)) {
  id<-R2$id[i]
  start<-R2$V2[i]
  end<-R2$V3[i]
  R2_seqs<-c(R2_seqs,substr(data[id],start = start,stop = end))
}
R2_seqs<-data.frame(id=names(R2_seqs),R2_seqs)
row.names(R2_seqs)<-NULL
res<-AAStringSet(R2_seqs$R2_seqs)
names(res)<-R2_seqs$id
writeXStringSet(res,"synthesized.RuvC_II.seqs.10_25.fa")

#R3(-13,24)
R3<-merge(data1[,c("id","R3_pos")],ls,by="id",all.x=T)
R3$V2<-R3$R3_pos-13
R3$V3<-R3$R3_pos+24
R3$V2[R3$V2<1]<-1
R3$V3[R3$V3>R3$length]<-R3$length[R3$V3>R3$length]
R3_seqs<-c()
for (i in 1:nrow(R3)) {
  id<-R3$id[i]
  start<-R3$V2[i]
  end<-R3$V3[i]
  R3_seqs<-c(R3_seqs,substr(data[id],start = start,stop = end))
}
R3_seqs<-data.frame(id=names(R3_seqs),R3_seqs)
row.names(R3_seqs)<-NULL
res<-AAStringSet(R3_seqs$R3_seqs)
names(res)<-R3_seqs$id
writeXStringSet(res,"synthesized.RuvC_III.seqs.10_25.fa")

##用clustalo分别比对...
##合并clustalo比对
R1<-readAAStringSet("RuvC_I.seqs.new_10_25.clustalo.fa")
R2<-readAAStringSet("RuvC_II.seqs.new_10_25.clustalo.fa")
R3<-readAAStringSet("RuvC_III.seqs.new_10_25.clustalo.fa")

R1<-data.frame(id=names(R1),R1=as.character(R1))
row.names(R1)<-NULL
R1<-unique(R1)
R2<-data.frame(id=names(R2),R1=as.character(R2))
row.names(R2)<-NULL
R2<-unique(R2)
R3<-data.frame(id=names(R3),R1=as.character(R3))
row.names(R3)<-NULL
R3<-unique(R3)

Rall<-merge(R1,R2,by="id",all=T)
Rall<-merge(Rall,R3,by="id",all=T)
Rall_2<-na.omit(Rall)

final_seqs<-unlist(apply(Rall_2[,c(2:4)],1,paste,collapse=""))
out<-AAStringSet(final_seqs)
names(out)<-Rall_2$id
writeXStringSet(out,"concated_RuvC_seqs_10_25.new.fa")







