#! /usr/bin/env python
import os,sys
fname=sys.argv[1]
fnamelist=os.path.splitext(fname)
frpqra=open(fnamelist[0]+'.pqra','r')
frpqrt=open(fnamelist[0]+'.pqrt','r')
fw=open(fnamelist[0]+'.pqrta','w')
atomarea=[]
for line in frpqra:
        if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):
                aarea=line[78:90]
                atomarea.append(aarea)
        elif (line[:6]=='REMARK'): fw.write(line)
nowi=0
for line in frpqrt:
        if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):
                fw.write(line.strip()+atomarea[nowi]+'\n')
                nowi+=1;
fw.close();frpqra.close();frpqrt.close(); 
