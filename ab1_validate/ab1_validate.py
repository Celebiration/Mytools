#!/usr/local/anaconda/bin/python
import sys
import os
from Bio import SeqIO
import subprocess
import autosnapgene as snap
import pandas as pd
import numpy as np
import re
import csv
from collections import Counter

wkdir = sys.argv[1]
mapping = pd.read_csv(wkdir+'/mapping.csv',header=None)
result_file = sys.argv[2]

#functions:
def overlap(range1, range2):
	if range1[1] <= range2[0] or range2[1] <= range1[0]:
		return None
	return max(range1[0],range2[0]), min(range1[1],range2[1])

def extract_align_at(alignment, index):
	if index not in range(*alignment[0]):
		return None
	else:
		return ''.join([alignment[2][i] for i in alignment[3][index-alignment[0][0]]])

def most_frequent_element(lst):
	if not lst:
		return '.'
	counts = Counter(lst)
	max_count = max(counts.values())
	for elem, count in counts.items():
		if count == max_count:
			return elem

o = open(result_file,'w')
o.write("vector_file\ttarget_range\tab1_files\ttarget_seq\taligned_target_seq\taligned_seq\tis_same\n")
for i in range(len(mapping)):
	line = mapping.iloc[i,]
	vector_file,target_start,target_end,ab1_files=line
	vector = snap.parse(wkdir+'/target/'+vector_file).sequence
	target_range = (target_start-1, target_end)
	ab1_lst=[wkdir+'/ab1/'+ii for ii in re.split('[ ,]+',ab1_files)]

	align_lst=[]
	for ab1 in ab1_lst:
		if not os.path.exists(ab1+'.fastq'):
			with open(ab1+'.fastq', "w") as fastq_handle:
				for record in SeqIO.parse(ab1, "abi"):
					SeqIO.write(record, fastq_handle, "fastq")
		with open(ab1+'.fastq','r') as f:
			f.readline()
			seq=f.readline().strip()
		command=f'/usr/bin/Rscript /home/fengchr/staff/2024_9_23_sjq_primer/map_9_29/webserver/align.R {vector} {seq} local-global'
		ref_aligned,seq_aligned,ref_aligned_start,ref_aligned_end = subprocess.run(command, shell=True, capture_output=True, text=True).stdout.strip().split(" ")[-1].strip('"').split("|")
		pos_map=[]
		for i in range(len(ref_aligned)):
			if ref_aligned[i] != "-":
				pos_map.append([i])
			else:
				if len(pos_map):
					pos_map[-1].append(i)
		align_lst.append(((int(ref_aligned_start)-1,int(ref_aligned_end)),ref_aligned,seq_aligned,pos_map))
		# print(((int(ref_aligned_start)-1,int(ref_aligned_end)),ref_aligned,seq_aligned,pos_map))
		# o.write(f"{ab1}\t{seq}\t{ref}\t{ref_aligned}\t{seq_aligned}\t{1 if ref_aligned == seq_aligned else 0}\n")
	aligned_target = ''
	degenerate_seq = ''
	for ii in range(*target_range):
		t = vector[ii].upper()
		q_lst = []
		ind = False
		for iii in align_lst:
			tmp = extract_align_at(iii, ii)
			if tmp is None:
				continue
			if tmp.upper() == t:
				aligned_target += t
				degenerate_seq += t
				ind = True
				break
			q_lst.append(tmp)
		if not ind:
			tmp = most_frequent_element(q_lst)
			degenerate_seq += tmp
			aligned_target += t + '-' * (len(tmp)-1)
	o.write(f"{vector_file}\t{target_range}\t{ab1_files}\t{vector[target_range[0]:target_range[1]]}\t{aligned_target}\t{degenerate_seq}\t{degenerate_seq==aligned_target}\n")
o.close()