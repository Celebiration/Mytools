#!/usr/bin/bash

fa1=$1
fa=${fa1##*/}
fa0=${fa%.*}
hmm1=$2
hmm=${hmm1##*/}
hmm0=${hmm%.*}
type=$3

if [ $type == "1" ];then
hmmsearch -o ${fa0}.${hmm0}.hmmout -A ${fa0}.${hmm0}.ali --tblout ${fa0}.${hmm0}.per_seq -E 30 --domE 80 --max $hmm1 $fa1
fi
if [ $type == "2" ];then
hmmsearch -o ${fa0}.${hmm0}.hmmout -A ${fa0}.${hmm0}.ali --tblout ${fa0}.${hmm0}.per_seq --cut_ga --max $hmm1 $fa1
fi