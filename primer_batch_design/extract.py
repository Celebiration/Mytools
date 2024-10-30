#!/usr/local/anaconda/bin/python
import sys
import re
import pandas as pd
input=str(sys.argv[1])
output=str(sys.argv[2])

data=pd.read_csv('seqs_all.tsv',sep="\t",header=None)

extracted=open(output,'w')
extracted.write("id\tprimer1_left\tprimer1_right\tprimer1_product_size\tprimer1_product\tprimer2_left\tprimer2_right\tprimer2_product_size\tprimer2_product\tprimer3_left\tprimer3_right\tprimer3_product_size\tprimer3_product")
with open(input,'r') as f:
	line=f.readline()
	while line:
		line=line.strip()
		if line.startswith("PRIMER PICKING RESULTS FOR"):
			id=line.split(" ")[-1]
			extracted.write("\n"+id)
		elif line.startswith("LEFT PRIMER"):
			p1left=line.split(" ")[-1]
			p1ampliconstart=int(re.split(r" +",line)[2])
			tmp=f.readline().strip()
			tmp=re.split(r" +", tmp)
			p1right=tmp[-1]
			p1ampliconend=int(tmp[2])+1
			p1amplicon=(data[1][data[0]==id].iloc[0])[p1ampliconstart:p1ampliconend]
			f.readline()
			f.readline()
			f.readline()
			p1size=f.readline().strip().split(" ")[2].strip(",")
			extracted.write("\t"+p1left+"\t"+p1right+"\t"+p1size+"\t"+p1amplicon)
		elif line.startswith("1 LEFT PRIMER"):
			p2left=line.split(" ")[-1]
			p2ampliconstart=int(re.split(r" +",line)[3])
			tmp=f.readline().strip()
			tmp=re.split(r" +", tmp)
			p2right=tmp[-1]
			p2ampliconend=int(tmp[2])+1
			p2amplicon=(data[1][data[0]==id].iloc[0])[p2ampliconstart:p2ampliconend]
			p2size=f.readline().strip().split(" ")[2].strip(",")
			extracted.write("\t"+p2left+"\t"+p2right+"\t"+p2size+"\t"+p2amplicon)
		elif line.startswith("2 LEFT PRIMER"):
			p3left=line.split(" ")[-1]
			p3ampliconstart=int(re.split(r" +",line)[3])
			tmp=f.readline().strip()
			tmp=re.split(r" +", tmp)
			p3right=tmp[-1]
			p3ampliconend=int(tmp[2])+1
			p3amplicon=(data[1][data[0]==id].iloc[0])[p3ampliconstart:p3ampliconend]
			p3size=f.readline().strip().split(" ")[2].strip(",")
			extracted.write("\t"+p3left+"\t"+p3right+"\t"+p3size+"\t"+p3amplicon)
		line=f.readline()
extracted.write("\n")
extracted.close()
			
		

		
