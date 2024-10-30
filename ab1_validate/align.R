suppressPackageStartupMessages(library(Biostrings))
Args<-commandArgs(trailingOnly=T)
ref<-Args[1]
seq<-Args[2]
type<-Args[3]

myfun<-function(seq,ref){
  strand<-"+"
  tmp<-pairwiseAlignment(DNAString(ref),DNAString(seq),type=type,gapOpening=7,gapExtension=5)
  tmp2<-pairwiseAlignment(DNAString(ref),reverseComplement(DNAString(seq)),type=type,gapOpening=7,gapExtension=5)
  if (score(tmp2) > score(tmp)) {
    tmp<-tmp2
	strand<-"-"
  }
  return(c(as.character(alignedPattern(tmp)),as.character(alignedSubject(tmp)),start(Biostrings::pattern(tmp)),end(Biostrings::pattern(tmp))))
}

out<-myfun(seq,ref)
print(paste(out[1],out[2],out[3],out[4],sep="|"))
