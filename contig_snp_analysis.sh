#!/usr/bin/bash
Usage()
{
    echo -e "contig_snp_analysis.sh -b base -f fq1 -r fq2 -m {bwa/bowtie2} -s hmm_start -e hmm_end -a realign_with_major_alleles"
}
echo -b "The current command is: $BASH_COMMAND"
realign_with_major_alleles=0
aligner=bwa
while getopts ':b:f:r:s:e:m:a' OPT; do
    case $OPT in
        b) base="$OPTARG";;
        f) fq1="$OPTARG";;
        r) fq2="$OPTARG";;
        s) hmm_start="$OPTARG";;
        e) hmm_end="$OPTARG";;
        m) aligner="$OPTARG";;
        a) realign_with_major_alleles=1;;
        *) Usage; exit 1;;
    esac
done

if [ -z $base ];then Usage; exit 1; fi
if [ -z $fq1 ];then Usage; exit 1; fi
if [ -z $fq2 ];then Usage; exit 1; fi
do_analysis=1
if [ -z $hmm_start ];then do_analysis=0; fi
if [ -z $hmm_end ];then do_analysis=0; fi

if [ $realign_with_major_alleles == 1 ];then
    echo "===============REALIGN WITH MAJOR ALLELES==============="
fi

if [ $aligner = bwa ];then
    if [ ! -f ${base}.bwa.F4.mapq60.sorted.bam ];then
        echo -e "\nAligning..."
        #align
        bwa index ${base}.fa
        bwa mem -t 128 ${base}.fa ${fq1} ${fq2} -o ${base}.bwa.sam >/dev/null 2>&1
        samtools view -u -F 4 -q 60 ${base}.bwa.sam > ${base}.bwa.F4.mapq60.bam
        rm ${base}.bwa.sam
        samtools sort ${base}.bwa.F4.mapq60.bam > ${base}.bwa.F4.mapq60.sorted.bam
        rm ${base}.bwa.F4.mapq60.bam
    else
        echo -e "\nUsing existing file: ${base}.bwa.F4.mapq60.sorted.bam"
    fi
    if [ ! -f ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam ];then
        echo -e "\nremoving duplicates..."
        #rm dupslicates:
        java -jar ~/software/picard/build/libs/picard.jar MarkDuplicates -I ${base}.bwa.F4.mapq60.sorted.bam -M ${base}.bwa.F4.mapq60.sorted.picard.dup.metrics.txt -O ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam --REMOVE_DUPLICATES true
        samtools index ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam
    else
        echo -e "\nUsing existing file: ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam"
    fi
    if [ $do_analysis == 1 ];then
    echo -e "\ncalling snp..."
    #call snp:
    source activate bcftools
    bcftools mpileup -Ou -A -f ${base}.fa ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam | bcftools call --ploidy 2 -Ov -mv -o ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.vcf
    gatk CreateSequenceDictionary -R ${base}.fa
    gatk SelectVariants -V ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.vcf -O ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.snp.vcf -select-type SNP -R ${base}.fa
    #summarize:
    echo -e "\nSUMMARIZE\n####################################"
    skip=`grep -P "^##" ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.snp.vcf|wc -l`
    ref_major_alt.R ${base} ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.snp.vcf ${skip} ${hmm_start} ${hmm_end}
    echo -e "####################################\n"
    fi
    if [ $realign_with_major_alleles == 1 ];then
        echo -e "\nrealign with major alleles..."
        base=${base}_major
        #re-process:
        ###
        #align
        echo -e "\nAligning..."
        bwa index ${base}.fa
        bwa mem -t 128 ${base}.fa ${fq1} ${fq2} -o ${base}.bwa.sam >/dev/null 2>&1
        samtools view -u -F 4 -q 60 ${base}.bwa.sam > ${base}.bwa.F4.mapq60.bam
        rm ${base}.bwa.sam
        samtools sort ${base}.bwa.F4.mapq60.bam > ${base}.bwa.F4.mapq60.sorted.bam
        rm ${base}.bwa.F4.mapq60.bam
        #rm dupslicates:
        echo -e "\nremoving duplicates..."
        java -jar ~/software/picard/build/libs/picard.jar MarkDuplicates -I ${base}.bwa.F4.mapq60.sorted.bam -M ${base}.bwa.F4.mapq60.sorted.picard.dup.metrics.txt -O ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam --REMOVE_DUPLICATES true
        samtools index ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam
        if [ $do_analysis == 1 ];then
        #call snp:
        echo -e "\ncalling snp..."
        conda activate bcftools
        bcftools mpileup -Ou -A -f ${base}.fa ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bam | bcftools call --ploidy 2 -Ov -mv -o ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.vcf
        gatk CreateSequenceDictionary -R ${base}.fa
        gatk SelectVariants -V ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.vcf -O ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.snp.vcf -select-type SNP -R ${base}.fa
        #summarize:
        echo -e "\nSUMMARIZE\n####################################"
        skip=`grep -P "^##" ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.snp.vcf|wc -l`
        ref_major_alt.R ${base} ${base}.bwa.F4.mapq60.sorted.picard_duprmed.bcftools.snp.vcf ${skip} ${hmm_start} ${hmm_end}
        echo -e "####################################\n"
        ###
        fi
    fi
    if [ -f ${base}_major.fa ];then rm ${base}_major.fa;fi
fi

if [ $aligner = bowtie2 ];then
    if [ ! -f ${base}.bowtie2.F4.sorted.bam ];then
        echo -e "\nAligning..."
        #align
        bowtie2-build ${base}.fa ${base}
        bowtie2 -x ${base} -q -p 128 -1 ${fq1} -2 ${fq2} > ${base}.bowtie2.sam 2>/dev/null
        samtools view -u -F 4 ${base}.bowtie2.sam > ${base}.bowtie2.F4.bam
        rm ${base}.bowtie2.sam
        samtools sort ${base}.bowtie2.F4.bam > ${base}.bowtie2.F4.sorted.bam
        rm ${base}.bowtie2.F4.bam
    else
        echo -e "\nUsing existing file: ${base}.bowtie2.F4.sorted.bam"
    fi
    if [ ! -f ${base}.bowtie2.F4.sorted.picard_duprmed.bam ];then
        echo -e "\nremoving duplicates..."
        #rm dupslicates:
        java -jar ~/software/picard/build/libs/picard.jar MarkDuplicates -I ${base}.bowtie2.F4.sorted.bam -M ${base}.bowtie2.F4.sorted.picard.dup.metrics.txt -O ${base}.bowtie2.F4.sorted.picard_duprmed.bam --REMOVE_DUPLICATES true
        samtools index ${base}.bowtie2.F4.sorted.picard_duprmed.bam
    else
        echo -e "\nUsing existing file: ${base}.bowtie2.F4.sorted.picard_duprmed.bam"
    fi
    if [ $do_analysis == 1 ];then
    echo -e "\ncalling snp..."
    #call snp:
    source activate bcftools
    bcftools mpileup -Ou -A -f ${base}.fa ${base}.bowtie2.F4.sorted.picard_duprmed.bam | bcftools call --ploidy 2 -Ov -mv -o ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.vcf
    gatk CreateSequenceDictionary -R ${base}.fa
    gatk SelectVariants -V ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.vcf -O ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.snp.vcf -select-type SNP -R ${base}.fa
    #summarize:
    echo -e "\nSUMMARIZE\n####################################"
    skip=`grep -P "^##" ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.snp.vcf|wc -l`
    ref_major_alt.R ${base} ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.snp.vcf ${skip} ${hmm_start} ${hmm_end}
    echo -e "####################################\n"
    fi
    if [ $realign_with_major_alleles == 1 ];then
        echo -e "\nrealign with major alleles..."
        base=${base}_major
        #re-process:
        ###
        #align
        echo -e "\nAligning..."
        bowtie2-build ${base}.fa ${base}
        bowtie2 -x ${base} -q -p 128 -1 ${fq1} -2 ${fq2} > ${base}.bowtie2.sam 2>/dev/null
        samtools view -u -F 4 -q 60 ${base}.bowtie2.sam > ${base}.bowtie2.F4.bam
        rm ${base}.bowtie2.sam
        samtools sort ${base}.bowtie2.F4.bam > ${base}.bowtie2.F4.sorted.bam
        rm ${base}.bowtie2.F4.bam
        #rm dupslicates:
        echo -e "\nremoving duplicates..."
        java -jar ~/software/picard/build/libs/picard.jar MarkDuplicates -I ${base}.bowtie2.F4.sorted.bam -M ${base}.bowtie2.F4.sorted.picard.dup.metrics.txt -O ${base}.bowtie2.F4.sorted.picard_duprmed.bam --REMOVE_DUPLICATES true
        samtools index ${base}.bowtie2.F4.sorted.picard_duprmed.bam
        if [ $do_analysis == 1 ];then
        #call snp:
        echo -e "\ncalling snp..."
        conda activate bcftools
        bcftools mpileup -Ou -A -f ${base}.fa ${base}.bowtie2.F4.sorted.picard_duprmed.bam | bcftools call --ploidy 2 -Ov -mv -o ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.vcf
        gatk CreateSequenceDictionary -R ${base}.fa
        gatk SelectVariants -V ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.vcf -O ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.snp.vcf -select-type SNP -R ${base}.fa
        #summarize:
        echo -e "\nSUMMARIZE\n####################################"
        skip=`grep -P "^##" ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.snp.vcf|wc -l`
        ref_major_alt.R ${base} ${base}.bowtie2.F4.sorted.picard_duprmed.bcftools.snp.vcf ${skip} ${hmm_start} ${hmm_end}
        echo -e "####################################\n"
        ###
        fi
    fi
    if [ -f ${base}_major.fa ];then rm ${base}_major.fa;fi
fi