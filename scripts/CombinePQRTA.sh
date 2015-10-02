#! /bin/bash

mid=""
cid=`cat $1`

for dir in AMBER6 BONDI MBONDI MBONDI2
do
cd $dir

echo "#! /usr/bin/env python" >  combinePQRTA.py
echo "import os,sys" >>  combinePQRTA.py
echo "fname=sys.argv[1]" >>  combinePQRTA.py
echo "fnamelist=os.path.splitext(fname)" >>  combinePQRTA.py
echo "frpqra=open(fnamelist[0]+'.pqra','r')" >>  combinePQRTA.py
echo "frpqrt=open(fnamelist[0]+'.pqrt','r')" >>  combinePQRTA.py
echo "fw=open(fnamelist[0]+'.pqrta','w')" >>  combinePQRTA.py
echo "atomarea=[]" >>  combinePQRTA.py
echo "for line in frpqra:" >>  combinePQRTA.py
echo "        if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):" >>  combinePQRTA.py
echo "                aarea=line[78:90]" >>  combinePQRTA.py
echo "                atomarea.append(aarea)" >>  combinePQRTA.py
echo "        elif (line[:6]=='REMARK'): fw.write(line)" >>  combinePQRTA.py
echo "nowi=0" >>  combinePQRTA.py
echo "for line in frpqrt:" >>  combinePQRTA.py
echo "        if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):" >>  combinePQRTA.py
echo "                fw.write(line.strip()+atomarea[nowi]+'\n')" >>  combinePQRTA.py
echo "                nowi+=1;" >>  combinePQRTA.py
echo "fw.close();frpqra.close();frpqrt.close(); " >>  combinePQRTA.py

for i in $cid
do
cp PQRA/${i}${mid}_area.pqra ${i}${mid}.pqra

for subd in GAFF AMBER SYBYL BCC GAS
do
cp PQRT_${subd}/${i}${mid}.pqrt .
python combinePQRTA.py ${i}${mid}.pqrt
mv ${i}${mid}.pqrta PQRTA_${subd}
rm ${i}${mid}.pqrt
done

rm ${i}${mid}.pqra
done

cd ..
done
