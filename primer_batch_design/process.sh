#!/usr/bin/bash
file=$1
result=$2
username=$3
jobname=$4
species=$5
set -e

trap "python -u /var/www/platform/app/scripts/ngs/taskfailed.py $jobname $username" EXIT

Base_dir=$PWD
base_dir=''$Base_dir'/tmp/primer/'
work_dir='/var/www/platform/app/scripts/primer/'
source /home/yhh/.bashrc
source activate base
cd ''$base_dir'/data/'

#获取上传文件名
dir=${file##*/}
dir=${dir%.*}

cd $dir
cp $file ./target.tsv


#进入到压缩文件
a=`ls`
if [ ! -f target.tsv ]
then
    cd `find . -maxdepth 1 -type d |tail -1`
fi
#获取.txt文档的所有数据
dos2unix target.tsv
cp target.tsv $result/

echo -e "\n***********解压完成*************\n"
echo -e "\n正在处理数据....\n" 

#处理
case $species in
	0) genome_fa=/Yol_Data/resources/Gencode_human_ref/GRCh38.p13.genome.fa;;
	1) genome_fa=/Yol_Data/resources/rice_genome/ensembl_dataset/Oryza_sativa.IRGSP-1.0.dna.toplevel.fa;;
	2) genome_fa=/Yol_Data/resources/arabidopsis_thaliana_genome/ensembl_dataset/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa;;
esac

mkdir -p working
cd working
split -l 30 -d --additional-suffix=.tsv ../target.tsv target
echo -n > ../para.txt
for i in `ls *.tsv`;do
echo $i
num=${i:6:-4}
echo "/var/www/platform/app/scripts/primer/extract_flanking_seq.sh -i ${i} -o flanking_seqs${num}.tsv -l 300 -f ${genome_fa};python /var/www/platform/app/scripts/primer/Cas_primer_designer.py flanking_seqs${num}.tsv input${num}.txt 40;primer3_core --format_output --output=output${num}.txt input${num}.txt" >> ../para.txt
done
echo "开始运行parafly..."
ParaFly -c ../para.txt -CPU 10
echo "完成。"
echo "开始提取结果..."
cat output* >> $result/output_all.txt
echo -n > seqs_all.tsv
for i in `ls flanking_seqs*`;do sed '1d' $i | awk -v OFS="\t" '{print $1,$2$3$4}' >> seqs_all.tsv;done
/var/www/platform/app/scripts/primer/extract.py $result/output_all.txt $result/output_all.extracted.tsv

echo "分析完成\n"
echo -e "\n压缩文件中........\n"
cd $result
cd ..
zip -r "$dir.zip" $dir
echo -e "\n压缩完成,请点击结果文件下载\n"

python -u '/var/www/platform/app/scripts/ngs/updateMysql.py' $dir $username

trap - EXIT