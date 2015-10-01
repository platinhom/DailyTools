#! /usr/bin/env python

import os,sys
fname=sys.argv[1]
fnamelist=os.path.splitext(fname)

frac=open(fnamelist[0]+".ac",'r')
frpa=open("partition_area.txt")
frpqr=open(fnamelist[0]+".pqr","r")
fw=open(fnamelist[0]+".pqra","w")

actype=[]
atomarea=[]

for line in frac:
	if (line[:6]=="ATOM  " or line[:6]=="HETATM"):
		at=line[64:74]
		actype.append(at)
for line in frpa:
	if (len(line.strip().split())==2):
		atomarea.append("%12.6f" % float(line.split()[1]))
nowi=0
for line in frpqr:
	if (line[:6]=="ATOM  " or line[:6]=="HETATM"):
		fw.write(line.strip()+atomarea[nowi]+actype[nowi]+'\n')
		nowi+=1;


