#! /usr/bin/env python
import os,sys
def analyseLine(line):
    tmp=line.strip().split(':')
    types=tmp[0].split()
    areas=tmp[1].split()
    if (len(types) !=len(areas)):
        print "Error line: \n"+line;
        exit(1)
    ta={}
    for i in range(1,len(types)):
        ta[types[i]]=areas[i]
    return ta;

fname=sys.argv[1];
fnamelist=os.path.splitext(fname);
fr=open(fname);
i=1;
types=[]
lennow=0;
firstline=""
data=[]
dataid=[]
for line in fr:
	if (i is 1):
		firstline=line;
		i+=1;
		continue;
	if (i is 2):
		tmp=line.split(":")[0].strip().split()
		types=tmp[1:]
		lennow=len(types);
		print "Starting type number: "+str(lennow);
		data.append(analyseLine(line))
		dataid.append(tmp[0])
		i+=1;
		continue;
	data.append(analyseLine(line))
	tmp=line.split(":")[0].strip().split();
	dataid.append(tmp[0])
	if (len(tmp)-1!=lennow):
		print "Line "+str(i)+" type number: "+str(len(tmp));
	for t in tmp[1:]:
		if (t not in types):
			print "Line "+str(i)+" has new type: "+t;
			types.append(t);
	i+=1

fw=open(fnamelist[0]+"_new"+fnamelist[1],'w');
fw.write("CID ");
for t in types:
	fw.write(t+" ");
fw.write('\n');

for inum in range(len(data)):
	fw.write(dataid[inum]+" ")
	for t in types:
		fw.write(data[inum].setdefault(t,"0.0")+" ");
	fw.write('\n')	

