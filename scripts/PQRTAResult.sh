#! /bin/bash

FPrefix="20151002-PC670-AArea"
mid=""
cid=`cat $1`

for dir in AMBER6 BONDI MBONDI MBONDI2
do
cd $dir

echo $dir GAFF > ${FPrefix}_${dir}_GAFF.prn
echo $dir AMBER > ${FPrefix}_${dir}_AMBER.prn
echo $dir SYBYL > ${FPrefix}_${dir}_SYBYL.prn
echo $dir BCC > ${FPrefix}_${dir}_BCC.prn
echo $dir GAS > ${FPrefix}_${dir}_GAS.prn

echo "#! /usr/bin/env python" >GetTypeAreaPQRTA.py
echo "import os,sys" >>GetTypeAreaPQRTA.py
echo "gaff=['br', 'c', 'c1', 'c2', 'c3', 'ca', 'cc', 'cd', 'ce', 'cf', 'cg', 'cl', 'cp', 'cx', 'cy', 'f', 'h1', 'h2', 'h3', 'h4', 'h5', 'ha', 'hc', 'hn', 'ho', 'hs', 'i', 'n', 'n1', 'n2', 'n3', 'na', 'nb', 'nc', 'nd', 'ne', 'nf', 'nh', 'no', 'o', 'oh', 'os', 'p5', 's', 's4', 's6', 'sh', 'ss', 'sy']" >>GetTypeAreaPQRTA.py
echo "amber=['Br', 'C', 'C*', 'CA', 'CB', 'CD', 'CK', 'Cl', 'CM', 'CN', 'CQ', 'CR', 'CT', 'CV', 'CW', 'CZ', 'DU', 'F', 'H', 'H1', 'H2', 'H3', 'H4', 'H5', 'HA', 'HC', 'HO', 'HS', 'I', 'N', 'N*', 'N1', 'N2', 'NA', 'NB', 'NC', 'NO', 'NT', 'O', 'O2', 'OH', 'OS', 'OW', 'P', 'S', 'SH', 'SO']" >>GetTypeAreaPQRTA.py
echo "sybyl=['Br', 'C.1', 'C.2', 'C.3', 'C.ar', 'Cl', 'F', 'H', 'I', 'N.1', 'N.2', 'N.3', 'N.am', 'N.ar', 'N.pl3', 'O.2', 'O.3', 'P.3', 'S.2', 'S.3', 'S.o', 'S.o2']" >>GetTypeAreaPQRTA.py
echo "bcc=['11', '12', '13', '14', '15', '16', '17', '21', '22', '23', '24', '25', '31', '32', '33', '42', '51', '52', '53', '71', '72', '73', '74', '91']" >>GetTypeAreaPQRTA.py
echo "gas=['br', 'c1', 'c2', 'c3', 'cl', 'f', 'h', 'i', 'n1', 'n2', 'n3', 'na', 'o2', 'o3', 'os', 'p', 's2', 's3', 'so', 'so2']" >>GetTypeAreaPQRTA.py
echo "if (__name__ == '__main__'):" >>GetTypeAreaPQRTA.py
echo "	fname=sys.argv[1]" >>GetTypeAreaPQRTA.py
echo "	fnamelist=os.path.splitext(fname)" >>GetTypeAreaPQRTA.py
echo "	if (fnamelist[1].lower()!='.pqrta'):" >>GetTypeAreaPQRTA.py
echo "		print 'Input should be pqrta format!'" >>GetTypeAreaPQRTA.py
echo "		exit(1)" >>GetTypeAreaPQRTA.py
echo "	fnum=fnamelist[0].split('_')[0];" >>GetTypeAreaPQRTA.py
echo "	settype=[]" >>GetTypeAreaPQRTA.py
echo "	if (sys.argv[2].lower()=='gaff'):settype=gaff" >>GetTypeAreaPQRTA.py
echo "	elif (sys.argv[2].lower()=='amber'):settype=amber" >>GetTypeAreaPQRTA.py
echo "	elif (sys.argv[2].lower()=='sybyl'):settype=sybyl" >>GetTypeAreaPQRTA.py
echo "	elif (sys.argv[2].lower()=='bcc'):settype=bcc" >>GetTypeAreaPQRTA.py
echo "	elif (sys.argv[2].lower()=='gas'):settype=gas" >>GetTypeAreaPQRTA.py
echo "	else:" >>GetTypeAreaPQRTA.py
echo "		print 'Atom type set should be given, gaff, amber, sybyl, bcc or gas!'" >>GetTypeAreaPQRTA.py
echo "		exit(1)" >>GetTypeAreaPQRTA.py
echo "	areatype={}" >>GetTypeAreaPQRTA.py
echo "	for t in settype:" >>GetTypeAreaPQRTA.py
echo "		areatype[t]=0.0" >>GetTypeAreaPQRTA.py
echo "	fr=open(fname)" >>GetTypeAreaPQRTA.py
echo "	for line in fr:" >>GetTypeAreaPQRTA.py
echo "		# Each atom" >>GetTypeAreaPQRTA.py
echo "		if (line[:4]=='ATOM' or line[:6]=='HETATM'):" >>GetTypeAreaPQRTA.py
echo "			tmp=line.split();" >>GetTypeAreaPQRTA.py
echo "			atype=tmp[-2].strip();" >>GetTypeAreaPQRTA.py
echo "			aarea=float(tmp[-1].strip());" >>GetTypeAreaPQRTA.py
echo "			if (atype not in settype): settype.append(atype);" >>GetTypeAreaPQRTA.py
echo "			areatype[atype]=areatype.setdefault(atype,0.0)+aarea;" >>GetTypeAreaPQRTA.py
echo "	fr.close()" >>GetTypeAreaPQRTA.py
echo "	outputatype=fnum+' '" >>GetTypeAreaPQRTA.py
echo "	outputaarea=fnum+' '" >>GetTypeAreaPQRTA.py
echo "	for atype in settype:" >>GetTypeAreaPQRTA.py
echo "		outputatype=outputatype+atype+' '" >>GetTypeAreaPQRTA.py
echo "		outputaarea=outputaarea+str(areatype[atype])+' ';" >>GetTypeAreaPQRTA.py
echo "	print outputatype+' : '+outputaarea;" >>GetTypeAreaPQRTA.py


for subd in GAFF AMBER SYBYL BCC GAS
do
cd PQRTA_$subd

for i in $cid
do
lsubd=`echo $subd | tr 'A-Z' 'a-z'`
result=`python ../GetTypeAreaPQRTA.py ${i}${mid}.pqrta $lsubd`
echo $result >> ../${FPrefix}_${dir}_${subd}.prn
done

echo "#! /usr/bin/env python" >> formatPQRTA.py
echo "import os,sys" >> formatPQRTA.py
echo "def analyseLine(line):" >> formatPQRTA.py
echo "    tmp=line.strip().split(':')" >> formatPQRTA.py
echo "    types=tmp[0].split()" >> formatPQRTA.py
echo "    areas=tmp[1].split()" >> formatPQRTA.py
echo "    if (len(types) !=len(areas)):" >> formatPQRTA.py
echo "        print 'Error line: \n'+line;" >> formatPQRTA.py
echo "        exit(1)" >> formatPQRTA.py
echo "    ta={}" >> formatPQRTA.py
echo "    for i in range(1,len(types)):" >> formatPQRTA.py
echo "        ta[types[i]]=areas[i]" >> formatPQRTA.py
echo "    return ta;" >> formatPQRTA.py
echo "fname=sys.argv[1];" >> formatPQRTA.py
echo "fnamelist=os.path.splitext(fname);" >> formatPQRTA.py
echo "fr=open(fname);" >> formatPQRTA.py
echo "i=1;" >> formatPQRTA.py
echo "types=[]" >> formatPQRTA.py
echo "lennow=0;" >> formatPQRTA.py
echo "firstline=''" >> formatPQRTA.py
echo "data=[]" >> formatPQRTA.py
echo "dataid=[]" >> formatPQRTA.py
echo "for line in fr:" >> formatPQRTA.py
echo "	if (i is 1):" >> formatPQRTA.py
echo "		firstline=line;" >> formatPQRTA.py
echo "		i+=1;" >> formatPQRTA.py
echo "		continue;" >> formatPQRTA.py
echo "	if (i is 2):" >> formatPQRTA.py
echo "		tmp=line.split(':')[0].strip().split()" >> formatPQRTA.py
echo "		types=tmp[1:]" >> formatPQRTA.py
echo "		lennow=len(types);" >> formatPQRTA.py
echo "		print 'Starting type number: '+str(lennow);" >> formatPQRTA.py
echo "		data.append(analyseLine(line))" >> formatPQRTA.py
echo "		dataid.append(tmp[0])" >> formatPQRTA.py
echo "		i+=1;" >> formatPQRTA.py
echo "		continue;" >> formatPQRTA.py
echo "	data.append(analyseLine(line))" >> formatPQRTA.py
echo "	tmp=line.split(':')[0].strip().split();" >> formatPQRTA.py
echo "	dataid.append(tmp[0])" >> formatPQRTA.py
echo "	if (len(tmp)-1!=lennow):" >> formatPQRTA.py
echo "		print 'Line '+str(i)+' type number: '+str(len(tmp));" >> formatPQRTA.py
echo "	for t in tmp[1:]:" >> formatPQRTA.py
echo "		if (t not in types):" >> formatPQRTA.py
echo "			print 'Line '+str(i)+' has new type: '+t;" >> formatPQRTA.py
echo "			types.append(t);" >> formatPQRTA.py
echo "	i+=1" >> formatPQRTA.py
echo "fw=open(fnamelist[0]+'_new'+fnamelist[1],'w');" >> formatPQRTA.py
echo "fw.write('CID ');" >> formatPQRTA.py
echo "for t in types:" >> formatPQRTA.py
echo "	fw.write(t+' ');" >> formatPQRTA.py
echo "fw.write('\n');" >> formatPQRTA.py
echo "for inum in range(len(data)):" >> formatPQRTA.py
echo "	fw.write(dataid[inum]+' ')" >> formatPQRTA.py
echo "	for t in types:" >> formatPQRTA.py
echo "		fw.write(data[inum].setdefault(t,'0.0')+' ');" >> formatPQRTA.py
echo "	fw.write('\n')	" >> formatPQRTA.py

python formatPQRTA.py ../${FPrefix}_${dir}_${subd}.prn
mv ../${FPrefix}_${dir}_${subd}.prn .
rm formatPQRTA.py
cd ..
done


cd ..
done
