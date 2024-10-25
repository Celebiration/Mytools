setwd("D:\\projects\\new_cas\\Cas9d\\placement_4_10")
library(ggtree)
library(ape)
library(tidytree)
library(treeio)
library(ggplot2)
nw<-'RAxML_portableTree.placement.newick'
jplace<-'RAxML_portableTree.placement.jplace'
mytree<-read.tree(nw)

nodeid.tbl_tree <- utils::getFromNamespace("nodeid.tbl_tree", "tidytree")
rootnode.tbl_tree <- utils::getFromNamespace("rootnode.tbl_tree", "tidytree")
offspring.tbl_tree <- utils::getFromNamespace("offspring.tbl_tree", "tidytree")
offspring.tbl_tree_item <- utils::getFromNamespace(".offspring.tbl_tree_item", "tidytree")
child.tbl_tree <- utils::getFromNamespace("child.tbl_tree", "tidytree")
parent.tbl_tree <- utils::getFromNamespace("parent.tbl_tree", "tidytree")


classify<-function(id){
  if (startsWith(id,"iscb")) {
    return("Iscb")
  }
  if (startsWith(id,"HEARO")) {
    return("HEARO")
  }
  if (startsWith(id,"II_D")) {
    return("Cas9d")
  }
  if (startsWith(id,"II_C2")) {
    return("Cas9c2")
  }
  if (startsWith(id,"UniRef90") | id %in% c('CjCas9','NmeCas9','St1Cas9','SaCas9','SpCas9','FnCas9')) {
    return("ref")
  }
  if (startsWith(id,"new|JGI")) {
    return("place_JGI")
  }
  if (startsWith(id,"new|ENA")) {
    return("place_ENA")
  }
  if (startsWith(id,"new|patent")) {
    return("place_patent")
  }
  if (startsWith(id,"new")) {
    return("place")
  }
  return("other")
}
mycolor<-data.frame(class=c("Iscb","HEARO","Cas9d","Cas9c2","ref","place_JGI","place_ENA","place_patent","place","other"),color=c("#C90076","#6A329F","#2986CC","#8FCE00","#FFD966","#35F4F9","#FF8F8F","#C6C6C6","red","black"))
#mycolor<-data.frame(class=c("Iscb","HEARO","Cas9d","Cas9c2","ref","place","other"),color=c("#C90076","#6A329F","#2986CC","#8FCE00","#FFD966","#35F4F9","black"))

anno_color<-data.frame(label=mytree$tip.label,color=unlist(lapply(mytree$tip.label,classify)))
mytree2 <- full_join(mytree, anno_color, by = 'label')

graphics.off()
pdf("seq.rmdup.original_tree.pdf",width = 12,height = 10)
ggtree(mytree2,aes(color=color),layout = 'fan', open.angle=10,size=0.3)+
  geom_tippoint(aes(color=color),size=0.7)+
  scale_color_manual(breaks = mycolor$class,values = mycolor$color)+
  theme(legend.position = c(0.9,0.5),
        text = element_text(size = 20),
        plot.caption = element_text(hjust=0.5,vjust=30))+
  labs(caption="Original")
dev.off()

graphics.off()
pdf("filtered_protein.sample.iqtree.pdf",width = 20,height = 17)
ggtree(mytree2,aes(color=color),layout = 'fan', open.angle=10,size=0.3)+
  geom_tippoint(aes(color=color),size=0.7)+
  scale_color_manual(breaks = mycolor$class,values = mycolor$color)+
  theme(legend.position = c(0.9,0.5),
        text = element_text(size = 20),
        plot.caption = element_text(hjust=0.5,vjust=30))+
  labs(caption="Placement")
dev.off()

graphics.off()
pdf("placement.circular.pdf",width = 20,height = 17)
ggtree(mytree2,aes(color=color),layout = 'circular', open.angle=10,size=0.3)+
  geom_tippoint(aes(color=color),size=0.7)+
  scale_color_manual(breaks = mycolor$class,values = mycolor$color)+
  theme(legend.position = c(0.9,0.5),
        text = element_text(size = 20),
        plot.caption = element_text(hjust=0.5,vjust=30))+
  geom_tiplab(size=1,offset = 0.04)
dev.off()




