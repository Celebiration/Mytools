#!/usr/bin/bash
input=$1
output=$2
echo -n > $output
while read line
do
#提取序列
tmp=`echo ${line}|awk -v OFS="\t" -v FS="[:\t ]" '{print $1,$2-25,$2+25}'`
echo $tmp
seq=`seqkit subseq --bed <(echo $tmp|sed 's/ /\t/g') -w 0 /Yol_Data/resources/Gencode_human_ref/GRCh38.p13.genome.fa|tail -1`
#ssearch36 -b 1 -d 1 -a -f -5 -g -4 -n <(echo -e ">subject\n${seq}") <(echo -e ">sgRNA\n${sgRNA}")|grep -A 2 "^sgRNA-"
echo -e "${line}\t${seq}" >> $output
done < $input
