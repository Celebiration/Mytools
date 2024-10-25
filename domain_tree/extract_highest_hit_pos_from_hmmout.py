#!/usr/local/anaconda/bin/python
import sys
import re

hmmfile=str(sys.argv[1])
id=str(sys.argv[2])
hmm_acc=str(sys.argv[3])
hmm_pos=int(sys.argv[4])


f=open(hmmfile,'r')

line=f.readline().strip()
while not (line.startswith('Query:') and re.split(" +",line)[1]==hmm_acc):
    line=f.readline().strip()
line=f.readline().strip()

def myfun(str,skip_char,target_pos):#找出字符串str中第target_pos个不为skip_char的字符位置
    count = 0
    position = None
    for i, char in enumerate(str):
        if char != skip_char:
            count += 1
            if count == target_pos:
                position = i
                break
    if position != None:
        return(position)
    else:
        return(-1)
def myfun_r(str,skip_char,target_pos):#找出字符串str中target_pos位字符的真实序列位置
    return(len(str[:(target_pos+1)].replace(skip_char,'')))

def find_target_pos(ref,target,hmm_pos):
    return(target[0]-1+myfun_r(target[2],'-',myfun(ref[2],'.',hmm_pos-ref[0]+1)))

while line != ">> "+id:
    line=f.readline().strip()

tmp=f.readline().strip()
if tmp.startswith('[No '):
    print(id+"\tNA")
    exit()
f.readline()

highest_score=-10000
highest_index=-1
line=f.readline().strip()
while line != "":
    values=re.split(" +",line)
    if float(values[2])>float(highest_score):
        highest_score=float(values[2])
        highest_index=int(values[0])
    line=f.readline().strip()
if highest_index==-1:
    raise ValueError(id+"没找出highest_index!")

ref=(-1,-1,"")
target=(-1,-1,"")
while not line.startswith(">>"):
    if line.startswith("== domain "+str(highest_index)+" "):
        ref_line=re.split(" +",f.readline().strip())
        ref=(int(ref_line[1]),int(ref_line[3]),ref_line[2])
        f.readline()
        target_line=re.split(" +",f.readline().strip())
        target=(int(target_line[1]),int(target_line[3]),target_line[2])
        break
    line=f.readline().strip()
if target==(-1,-1,""):
    raise ValueError("没找到对应的比对！")
if hmm_pos < ref[0] or hmm_pos > ref[1]:
    print(id+"\tNA")
else:
    print(id+"\t"+str(find_target_pos(ref,target,hmm_pos)))
