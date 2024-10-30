#!/usr/local/anaconda/bin/python
import sys
import os
import pandas as pd

input=sys.argv[1]
#input需要包含以下列：
#id	upstream	sg_seq	downstream
output=sys.argv[2]
margin=int(sys.argv[3])#20

data=pd.read_csv(input,sep="\t")

f=open(output,'w')
f.write("PRIMER_TASK=generic\nPRIMER_PICK_LEFT_PRIMER=1\nPRIMER_PICK_INTERNAL_OLIGO=0\nPRIMER_PICK_RIGHT_PRIMER=1\nPRIMER_PRODUCT_SIZE_RANGE=100-250\nPRIMER_OPT_SIZE=20\nPRIMER_MIN_SIZE=18\nPRIMER_MAX_SIZE=27\nPRIMER_MAX_NS_ACCEPTED=0\nPRIMER_MIN_TM=55.0\nPRIMER_OPT_TM=60.0\nPRIMER_MAX_TM=65.0\nPRIMER_NUM_RETURN=3\nPRIMER_EXPLAIN_FLAG=1\n")
if len(data)==0:
	print("There's no data in "+input+"!")
	sys.exit(1)
for i in range(len(data)):
	f.write("SEQUENCE_ID="+data.iloc[i,]["id"]+"\n")
	f.write("SEQUENCE_TEMPLATE="+data.iloc[i,]["upstream"]+data.iloc[i,]["sg_seq"]+data.iloc[i,]["downstream"]+"\n")
	f.write("SEQUENCE_TARGET="+str(len(data.iloc[i,]["upstream"]))+","+str(len(data.iloc[i,]["sg_seq"]))+"\n")
	f.write("SEQUENCE_EXCLUDED_REGION="+str(len(data.iloc[i,]["upstream"])-margin)+","+str(margin)+" "+str(len(data.iloc[i,]["upstream"])+len(data.iloc[i,]["sg_seq"]))+","+str(margin)+"\n")
	f.write("=\n")
f.close()
