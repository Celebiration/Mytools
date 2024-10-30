#!/usr/bin/bash
Usage()
{
    echo "$0 -i input.tsv -o output.tsv -l flank_length -f genome.fa"
}
flank_len=300
genome_fa=/Yol_Data/resources/Gencode_human_ref/GRCh38.p13.genome.fa

while getopts 'i:o:l:f:' OPT; do
    case $OPT in
        i) input="$OPTARG";;
        o) output="$OPTARG";;
		l) flank_len="$OPTARG";;
		f) genome_fa="$OPTARG";;
        *) Usage; exit 1;;
    esac
done
if [ -z $input ];then Usage; exit 1; fi
if [ -z $output ];then Usage; exit 1; fi

echo -e "id\tupstream\tsg_seq\tdownstream" > $output
while read id chr start end strand;do
if [ "$strand" = "+" ];then
	sg_seq=`seqkit grep -p $chr $genome_fa|seqkit subseq --quiet --bed <(echo -e "${chr}\t${start}\t${end}") -w 0|tail -1`
    upstream=`seqkit grep -p $chr $genome_fa|seqkit subseq --quiet --bed <(echo -e "${chr}\t${start}\t${end}") -u $flank_len -w 0 -f|tail -1`
    downstream=`seqkit grep -p $chr $genome_fa|seqkit subseq --quiet --bed <(echo -e "${chr}\t${start}\t${end}") -d $flank_len -w 0 -f|tail -1`
else
	sg_seq=`seqkit grep -p $chr $genome_fa|seqkit subseq --quiet --bed <(echo -e "${chr}\t${start}\t${end}") -w 0|tail -1|recomp.py`
    downstream=`seqkit grep -p $chr $genome_fa|seqkit subseq --quiet --bed <(echo -e "${chr}\t${start}\t${end}") -u $flank_len -w 0 -f|tail -1|recomp.py`
    upstream=`seqkit grep -p $chr $genome_fa|seqkit subseq --quiet --bed <(echo -e "${chr}\t${start}\t${end}") -d $flank_len -w 0 -f|tail -1|recomp.py`
fi
echo -e "${id}\t${upstream}\t${sg_seq}\t${downstream}" >> $output
done < $input
