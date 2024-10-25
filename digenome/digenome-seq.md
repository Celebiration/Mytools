# Digenome-seq analysis pipeline

```bash
#adapter removing

#align
nohup STAR --runThreadN 120 --genomeDir hg38_STAR_ref --readFilesIn ${R1.fq.gz} ${R2.fq.gz} --readFilesCommand zcat --outSAMmapqUnique 60 --outFilterMultimapNmax 20 --sjdbOverhang 150 --outFileNamePrefix ${sample}_STAR/ --outSAMtype BAM SortedByCoordinate > ${sample}_STAR.log 2>&1 &

#digenome
for i in 4 5 6; do nohup digenome -G ${i} -q 1 -f 5 -r 5 -d 10 -R 0.1 -s 2.5 ${sample}.sorted.bam > ${sample}.sorted.digenome_overhang${i}_R0.1.tsv 2>${sample}.sorted.digenome_overhang${i}_R0.1.log & done
#make sure chromosom id is correct
#merge different overhang results
echo -n > ${sample}.sorted.digenome_R0.1.merged.tsv;for i in 4 5 6; do awk -v OFS="\t" -v c=${i} '{print $0,c}' ${sample}.sorted.digenome_overhang${i}_R0.1.tsv >> ${sample}.sorted.digenome_R0.1.merged.tsv;done

add_seq.sh ${sample}.sorted.digenome_R0.1.merged.tsv ${sample}.sorted.digenome_R0.1.merged.add_seq.tsv

digenome_align.R ${sample}.sorted.digenome_R0.1.merged.add_seq.tsv ${sample}.sorted.digenome_R0.1.merged.add_seq.aligned.tsv ${sgRNA}

digenome_visualization.py --identified_file ${sample}.sorted.digenome_R0.1.merged.add_seq.aligned.tsv --title ${sample}.R0.1 --target ${sgRNA}
```



extract bam for related positions：

```bash
sort -k1,1V -k2,2n ${prefix}.bed > ${prefix}.sorted.bed
bedtools merge -i ${prefix}.sorted.bed > ${prefix}.sorted.merged.bed
nohup samtools view -u -L ${prefix}.sorted.merged.bed -o ${sample}_sorted.${prefix}.bam ../../${sample}_sorted.bam > ${sample}_sorted.${prefix}.log 2>&1 &
samtools sort -o ${sample}_sorted.${prefix}.sorted.bam ${sample}_sorted.${prefix}.bam
samtools index ${sample}_sorted.${prefix}.sorted.bam
```

