#! /bin/bash
# File: mol2pqr.sh
# Author: Zhixiong Zhao, Last Updated: 2015.10.1
#
# Change the input molecule to pqr file with vdw radius.
# Input 1: molecule file in pdb/mol2/mpdb/pqr/ac format
# Input 2: output file format in ac/pdb/mol2/mpdb/xyzr/pqr/pqrt/pqra/pqrta format
# Input 3: charge type: no(default), bcc, mul, gas
# Input 4: atom type: gaff(default), amber, sybyl, bcc, gas
# Input 5: vdw radius set: mbondi(default), mbondi2, mbondi3, bondi, amber6, zap9 
#
# Usage: ./mol2pqr.sh input.mol2 pqr bcc gaff mbondi
# Need: python, ambertools, MS_Intersection(for pqra/pqrta)
# Custom: $AMBERHOME enviroment, MS_Intersection parameter, 

# Setup the amber environment. You should modify by your own environment
if [ -z $AMBERHOME ];then
	source /mnt/home/zhaozx/AmberTools/amber.sh
##if you are in HPCC
#module swap GNU Intel/13.0.1.117; module load OpenMPI/1.4.4; module load Amber/14v19;
	if [ -z $AMBERHOME ];then
		echo "No AmberTools is installed or its path can't be known!"
		exit
	fi
fi

probe=1.4
grid=0.2
solbuffer=4.0

if [ -z $1 ];then
	echo "Please assign the input file!"
	exit
fi

outFormat=`echo $2 | tr 'A-Z' 'a-z'`
if [ -z $outFormat ];then
	echo "No output format is given! Can be: "
	echo "  pdb/mol2/mpdb/pqr/ac/pqrt/pqra/pqrta"
	echo "  Now using pqr format..."
	outFormat=pqr
fi

chargetype=`echo $3 | tr 'A-Z' 'a-z'`
if [[ -z $chargetype || ( $chargetype != "bcc" && $chargetype != "mul" \
	&& $chargetype != "gas" && $chargetype != "no" ) ]];then
	echo "Please assign the charge method! Can be:"
	echo "  no:  Not to change the charges"
	echo "  bcc: for AM1-BCC charge"
	echo "  mul: for Mulliken charge"
	echo "  gas: for Gasteiger charge"
	echo "  cm1, cm2, esp, resp charge need more programs.. so don't support here."
	echo "  Now using no charge or origin charge...."
	chargetype=no
fi

# atom type as: gaff(default), amber, sybyl, bcc, gas.(In amber14)
atomtype=`echo $4 | tr 'A-Z' 'a-z'`
if [[ -z $atomtype || ( $atomtype != "gaff" && $atomtype != "amber" && \
	$atomtype != "sybyl" && $atomtype != "bcc" && $atomtype != "gas" ) ]];then
echo "Please assign the atom type in molecule! Can be:"
echo "gaff(default), amber, sybyl, bcc, gas.(In amber14)"
echo "Using default gaff...."
atomtype=gaff
fi

# vdw Type as: bondi, mbondi(default), mbondi2, mbondi3, amber6 (In amber14) and zap9.
vdwtype=`echo $5 | tr 'A-Z' 'a-z'`
if [[ -z $vdwtype || ( $vdwtype != "bondi" && $vdwtype != "mbondi" && $vdwtype != "mbondi2" \
	 && $vdwtype != "mbondi3" && $vdwtype != "amber6"  && $vdwtype != "zap9") ]];then
echo "Please assign the vdw radius type of atom! Can be:"
echo "  bondi, mbondi(default), mbondi2, mbondi3, amber6 (In amber14) and zap9"
echo "  Using default mbondi...."
vdwtype=mbondi
fi

MoreChangevdw="False"
if [[ $vdwtype = "zap9" ]];then
	MoreChangevdw=$vdwtype
	# use mbondi instead first
	vdwtype=mbondi
fi

#If need changevdw, change value to "True". And change the vdwtype value
#You can change it to any other string to deactivate it.
#changevdw="True"

outPQR="False"
if [[ ${outFormat:0:3} = "pqr" || $outFormat = "xyzr" ]];then
	outPQR="True"
fi

#mpdb will use mbondi, can't be changed!
if [ $outPQR = "True" ];then
	echo "Partial charge: $chargetype , atom type: $atomtype , vdw radiis: $vdwtype ."
else 
	echo "Partial charge: $chargetype , atom type: $atomtype ."
fi

ESES=""
if [[ ${outFormat} = "pqra" || ${outFormat} = "pqrta" ]];then
	if [ -f ./MS_Intersection ];then
		ESES="./MS_Intersection"
	elif which MS_Intersection 2>/dev/null; then
		ESES="MS_Intersection"
	else
		echo "No ESES program (MS_Intersection) exists!"
		exit
	fi
fi

basename=${1%.*}
exdname=${1##*.}

if [ $chargetype = "no" ];then # No need to change charges
	if [ $outPQR = "True" ];then #pqr/pqrt/pqra/pqrta
		if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
			antechamber -fi $exdname -fo ac -pf y -i $1 -at $atomtype -o ${basename}_gaff.ac
		elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
			antechamber -fi mpdb -fo ac -pf y -i $1 -at $atomtype -o ${basename}_gaff.ac
		else
			echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
			exit
		fi
	else #pdb/mol2/mpdb/ac
		if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
			antechamber -fi $exdname -fo $outFormat -pf y -i $1 -at $atomtype -o ${basename}.$outFormat
		elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
			antechamber -fi mpdb -fo $outFormat -pf y -i $1 -at $atomtype -o ${basename}.$outFormat
		else
			echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
			exit
		fi
	fi
else # Need to calculate charges.
	if [ $outPQR = "True" ];then #pqr/pqrt/pqra/pqrta
		if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
			antechamber -fi $exdname -fo ac -pf y -i $1 -c $chargetype -at $atomtype -o ${basename}_gaff.ac
		elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
			antechamber -fi mpdb -fo ac -pf y -i $1 -c $chargetype -at $atomtype -o ${basename}_gaff.ac
		else
			echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
			exit
		fi
	else #pdb/mol2/mpdb/ac
		if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
			antechamber -fi $exdname -fo $outFormat -pf y -i $1 -c $chargetype -at $atomtype -o ${basename}.$outFormat
		elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
			antechamber -fi mpdb -fo $outFormat -pf y -i $1 -c $chargetype -at $atomtype -o ${basename}.$outFormat
		else
			echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
			exit
		fi
	fi
fi 

# Convert to pqr file
if [ $outPQR = "True" ];then

	# Using tleap to generate top file
	# Leap only know gaff name and loadmol2, so convert back to mol2 file
	antechamber -fi ac -fo mol2 -pf y -i ${basename}_gaff.ac -o ${basename}_gaff.mol2
	parmchk -i ${basename}_gaff.mol2 -f mol2 -o ${basename}_gaff.frcmod
	echo "source leaprc.gaff">> ${basename}_gaff.leapin
	echo "loadamberparams ${basename}_gaff.frcmod" >> ${basename}_gaff.leapin
	echo "hom=loadmol2 ${basename}_gaff.mol2">> ${basename}_gaff.leapin
	echo "set default PBRadii $vdwtype" >> ${basename}_gaff.leapin
	echo "saveamberparm hom ${basename}_gaff.top ${basename}_gaff.crd">> ${basename}_gaff.leapin
	echo "quit">> ${basename}_gaff.leapin
	tleap -f ${basename}_gaff.leapin >/dev/null

	# Change the vdw radius by amber sets by parmed.py
	# Old version, now it use leap 'set default PBRadii type' instead.
	####
	#if [ $changevdw = "True" ];then
	#echo "changeRadii $vdwtype">>${basename}_gaff.parmedin
	#echo "outparm ${basename}_gaff.top">>${basename}_gaff.parmedin
	#parmed.py -p ${basename}_gaff.top -i ${basename}_gaff.parmedin -O > /dev/null
	#fi
	####

	# Use ambpdb to convert amber input to pqr.
	ambpdb -p ${basename}_gaff.top -pqr < ${basename}_gaff.crd > ${basename}.pqr

	# Change to Other radius...
	if [ ! $MoreChangevdw = "False" ];then
		if [ $MoreChangevdw = "zap9" ];then
		echo "#! /usr/bin/env python" > zap9radiusFromPQR.py
		echo "import os,sys" >> zap9radiusFromPQR.py
		echo "fname=sys.argv[1]" >> zap9radiusFromPQR.py
		echo "fnamelist=os.path.splitext(fname)" >> zap9radiusFromPQR.py
		echo "fwname=fnamelist[0]+'_zap9'+fnamelist[1]" >> zap9radiusFromPQR.py
		echo "fr=open(fname)" >> zap9radiusFromPQR.py
		echo "fw=open(fwname,'w')" >> zap9radiusFromPQR.py
		echo "for line in fr:" >> zap9radiusFromPQR.py
		echo "	if (line[:4]=='ATOM' or line[:6]=='HETATM'):" >> zap9radiusFromPQR.py
		echo "		element=line.split()[-1].upper();" >> zap9radiusFromPQR.py
		echo "		radius='   0.000';" >> zap9radiusFromPQR.py
		echo "		if (element=='H'): radius='   1.100';" >> zap9radiusFromPQR.py
		echo "		elif (element=='C'): radius='   1.870';" >> zap9radiusFromPQR.py
		echo "		elif (element=='N'): radius='   1.400';" >> zap9radiusFromPQR.py
		echo "		elif (element=='O'): radius='   1.760';" >> zap9radiusFromPQR.py
		echo "		elif (element=='F'): radius='   2.400';" >> zap9radiusFromPQR.py
		echo "		elif (element=='S'): radius='   2.150';" >> zap9radiusFromPQR.py
		echo "		elif (element=='CL'): radius='   1.820';" >> zap9radiusFromPQR.py
		echo "		newline=line[:62]+radius+line[70:];" >> zap9radiusFromPQR.py
		echo "		fw.write(newline);" >> zap9radiusFromPQR.py
		echo "	else:" >> zap9radiusFromPQR.py
		echo "		fw.write(line);" >> zap9radiusFromPQR.py
		echo "fr.close();" >> zap9radiusFromPQR.py
		echo "fw.close();" >> zap9radiusFromPQR.py
		python zap9radiusFromPQR.py ${basename}.pqr
		rm zap9radiusFromPQR.py ${basename}.pqr
		mv ${basename}_zap9.pqr ${basename}.pqr
		fi
	fi

	# Convert to xyzr
	if [ $outFormat = "xyzr" ];then
		echo "#! /usr/bin/env python" > pqr2xyzr.py
		echo "import os,sys" >> pqr2xyzr.py
		echo "fname=sys.argv[1]" >> pqr2xyzr.py
		echo "fnamelist=os.path.splitext(fname)" >> pqr2xyzr.py
		echo "fxyzr=open(fnamelist[0]+'.xyzr','w')" >> pqr2xyzr.py
		echo "fr=open(fname)" >> pqr2xyzr.py
		echo "for line in fr:" >> pqr2xyzr.py
		echo "	if (line[:4]=='ATOM' or line[:6]=='HETATM'):" >> pqr2xyzr.py
		echo "		radius='%10.5f' % float(line[62:70].strip());" >> pqr2xyzr.py
		echo "		xcoor='%10.5f' % float(line[30:38].strip());" >> pqr2xyzr.py
		echo "		ycoor='%10.5f' % float(line[38:46].strip());" >> pqr2xyzr.py
		echo "		zcoor='%10.5f' % float(line[46:54].strip());" >> pqr2xyzr.py
		echo "		xyzrstr=xcoor+ycoor+zcoor+radius+'\n';" >> pqr2xyzr.py
		echo "		fxyzr.write(xyzrstr);" >> pqr2xyzr.py
		echo "fr.close(); fxyzr.close()" >> pqr2xyzr.py
		python pqr2xyzr.py ${basename}.pqr
		rm pqr2xyzr.py
	fi

	# Convert to pqrt
	if [ ${outFormat:0:4} = "pqrt" ];then
		echo "#! /usr/bin/env python" > pqr_ac2pqrt.py
		echo "import os,sys" >> pqr_ac2pqrt.py
		echo "fname=sys.argv[1]" >> pqr_ac2pqrt.py
		echo "fnamelist=os.path.splitext(fname)" >> pqr_ac2pqrt.py
		echo "frac=open(sys.argv[2],'r')" >> pqr_ac2pqrt.py
		echo "frpqr=open(fnamelist[0]+'.pqr','r')" >> pqr_ac2pqrt.py
		echo "fw=open(fnamelist[0]+'.pqrt','w')" >> pqr_ac2pqrt.py
		echo "actype=[]" >> pqr_ac2pqrt.py
		echo "for line in frac:" >> pqr_ac2pqrt.py
		echo "	if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):" >> pqr_ac2pqrt.py
		echo "		at=line[64:74]" >> pqr_ac2pqrt.py
		echo "		actype.append(at)" >> pqr_ac2pqrt.py
		echo "nowi=0" >> pqr_ac2pqrt.py
		echo "for line in frpqr:" >> pqr_ac2pqrt.py
		echo "	if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):" >> pqr_ac2pqrt.py
		echo "		fw.write(line.strip()+actype[nowi]+'\n')" >> pqr_ac2pqrt.py
		echo "		nowi+=1;" >> pqr_ac2pqrt.py
		python pqr_ac2pqrt.py ${basename}.pqr ${basename}_gaff.ac
		rm pqr_ac2pqrt.py
		if [ ${outFormat} = "pqrt" ];then
			rm ${basename}.pqr
		fi
	fi

outPQRA=""
	# Convert to pqra
	if [[ $outFormat = "pqra" || $outFormat = "pqrta" ]];then
		# Come from ESES_ElementArea.py
		echo "#! /usr/bin/env python" > pqr2pqra.py
		echo "import os,sys" >> pqr2pqra.py
		echo "probe=${probe}" >> pqr2pqra.py
		echo "grid=${grid}" >> pqr2pqra.py
		echo "solbuffer=${solbuffer}" >> pqr2pqra.py
		echo "fname=sys.argv[1]" >> pqr2pqra.py
		echo "fnamelist=os.path.splitext(fname)" >> pqr2pqra.py
		echo "fxyzr=open(fnamelist[0]+'.xyzr','w')" >> pqr2pqra.py
		echo "fr=open(fname)" >> pqr2pqra.py
		echo "inlines=fr.readlines();" >> pqr2pqra.py
		echo "fr.close();" >> pqr2pqra.py
		echo "atomtypes=[];" >> pqr2pqra.py
		echo "for line in inlines:" >> pqr2pqra.py
		echo "	if (line[:4]=='ATOM' or line[:6]=='HETATM'):" >> pqr2pqra.py
		echo "		tmp=line.split();" >> pqr2pqra.py
		echo "		element=tmp[-1].upper();" >> pqr2pqra.py
		echo "		atomtypes.append(element);" >> pqr2pqra.py
		echo "		radius='%10.5f' % float(line[62:70].strip());" >> pqr2pqra.py
		echo "		xcoor='%10.5f' % float(line[30:38].strip());" >> pqr2pqra.py
		echo "		ycoor='%10.5f' % float(line[38:46].strip());" >> pqr2pqra.py
		echo "		zcoor='%10.5f' % float(line[46:54].strip());" >> pqr2pqra.py
		echo "		xyzrstr=xcoor+ycoor+zcoor+radius+'\n';" >> pqr2pqra.py
		echo "		fxyzr.write(xyzrstr);" >> pqr2pqra.py
		echo "fxyzr.close()" >> pqr2pqra.py
		echo "p=os.popen('./MS_Intersection '+fnamelist[0]+'.xyzr '+str(probe)+' '+str(grid)+' '+str(solbuffer),'r')" >> pqr2pqra.py
		echo "totalArea='0'" >> pqr2pqra.py
		echo "totalVolume='0'" >> pqr2pqra.py
		echo "while 1:" >> pqr2pqra.py
		echo "	line=p.readline();" >> pqr2pqra.py
		echo "	if 'area:' in line: totalArea=line.split(':')[1].split()[0]" >> pqr2pqra.py
		echo "	if 'volume:' in line: totalVolume=line.split(':')[1].split()[0]" >> pqr2pqra.py
		echo "	if not line:break" >> pqr2pqra.py
		echo "fa=open('partition_area.txt')" >> pqr2pqra.py
		echo "atomareas=[];# tmp save atom area by atom number" >> pqr2pqra.py
		echo "typedefault=['H','C','N','O','F','S','P','CL','BR','I'];" >> pqr2pqra.py
		echo "typeareas={'H':0.0,'C':0.0,'N':0.0,'O':0.0,'F':0.0,'S':0.0,'P':0.0,'CL':0.0,'BR':0.0,'I':0.0};" >> pqr2pqra.py
		echo "atomnum=0;" >> pqr2pqra.py
		echo "for line in fa:" >> pqr2pqra.py
		echo "	tmp=line.split();" >> pqr2pqra.py
		echo "	atomarea='%12.6f' % float(tmp[1]);" >> pqr2pqra.py
		echo "	atomareas.append(atomarea);" >> pqr2pqra.py
		echo "	atype=atomtypes[atomnum];" >> pqr2pqra.py
		echo "	typeareas[atype]=typeareas.setdefault(atype,0.0)+float(tmp[1]);" >> pqr2pqra.py
		echo "	atomnum=atomnum+1;" >> pqr2pqra.py
		echo "fa.close()" >> pqr2pqra.py
		echo "fwname=fnamelist[0]+'.pqra'" >> pqr2pqra.py
		echo "fw=open(fwname,'w')" >> pqr2pqra.py
		echo "typeused=['H','C','N','O','F','S','P','CL','BR','I'];" >> pqr2pqra.py
		echo "for i in typeareas.iterkeys():" >> pqr2pqra.py
		echo "	if i not in typeused:typeused.append(i);" >> pqr2pqra.py
		echo "outputelearea=fnamelist[0]+' Areas: '+totalArea+' Volumes: '+totalVolume+' ';" >> pqr2pqra.py
		echo "fw.write('REMARK  AREAS  '+totalArea+'\n');" >> pqr2pqra.py
		echo "fw.write('REMARK  VOLUMES  '+totalVolume+'\n');	" >> pqr2pqra.py
		echo "for element in typedefault:" >> pqr2pqra.py
		echo "	fw.write('REMARK  AREA  '+'%2s'%element+'  '+'%20.6f'%typeareas.get(element,0.0)+'\n');" >> pqr2pqra.py
		echo "	outputelearea=outputelearea+element+': '+str(typeareas[element])+' ';" >> pqr2pqra.py
		echo "print outputelearea" >> pqr2pqra.py
		echo "fr=open(fname)" >> pqr2pqra.py
		echo "atomnum=0;" >> pqr2pqra.py
		echo "for line in fr:" >> pqr2pqra.py
		echo "	if (line[:4]=='ATOM' or line[:6]=='HETATM'):" >> pqr2pqra.py
		echo "		tmp=line.split();" >> pqr2pqra.py
		echo "		element=tmp[-1].upper();" >> pqr2pqra.py
		echo "		newline=line.strip('\n')+atomareas[atomnum]+'\n';" >> pqr2pqra.py
		echo "		fw.write(newline);" >> pqr2pqra.py
		echo "		atomnum=atomnum+1;" >> pqr2pqra.py
		echo "	else:" >> pqr2pqra.py
		echo "		fw.write(line);" >> pqr2pqra.py
		echo "fr.close();" >> pqr2pqra.py
		echo "fw.close();" >> pqr2pqra.py
		outPQRA=`python pqr2pqra.py ${basename}.pqr`
		rm pqr2pqra.py ${basename}.xyzr ${basename}.pqr bounding_box.txt grid_info.txt intersection_info.txt partition_area.txt;
	fi

	# Convert to pqrta
	if [ $outFormat = "pqrta" ];then
		echo "#! /usr/bin/env python" > combine2pqrta.py
		echo "import os,sys" >> combine2pqrta.py
		echo "fname=sys.argv[1]" >> combine2pqrta.py
		echo "fnamelist=os.path.splitext(fname)" >> combine2pqrta.py
		echo "frpqra=open(fnamelist[0]+'.pqra','r')" >> combine2pqrta.py
		echo "frpqrt=open(fnamelist[0]+'.pqrt','r')" >> combine2pqrta.py
		echo "fw=open(fnamelist[0]+'.pqrta','w')" >> combine2pqrta.py
		echo "atomarea=[]" >> combine2pqrta.py
		echo "for line in frpqra:" >> combine2pqrta.py
		echo "	if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):" >> combine2pqrta.py
		echo "		aarea=line[78:90]" >> combine2pqrta.py
		echo "		atomarea.append(aarea)" >> combine2pqrta.py
		echo "	elif (line[:6]=='REMARK'): fw.write(line)">> combine2pqrta.py
		echo "nowi=0" >> combine2pqrta.py
		echo "for line in frpqrt:" >> combine2pqrta.py
		echo "	if (line[:6]=='ATOM  ' or line[:6]=='HETATM'):" >> combine2pqrta.py
		echo "		fw.write(line.strip()+atomarea[nowi]+'\n')" >> combine2pqrta.py
		echo "		nowi+=1;" >> combine2pqrta.py
		echo "fw.close();frpqra.close();frpqrt.close();" >> combine2pqrta.py
		python combine2pqrta.py ${basename}.pqrt ${basename}.pqra
		rm combine2pqrta.py ${basename}.pqrt ${basename}.pqra
	fi
	
	rm ${basename}_gaff.* leap.log
fi
