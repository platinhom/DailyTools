#! /bin/bash
# File: calcG09RESP.sh
# Author: Zhixiong Zhao, 2015-9-17
#
# Calculate Molecule ESP/RESP charge via Amber/G09.
# Usage: ./calcG09RESP.sh input.mol2 
# Input: molecule file in pdb/mol2 format
# Need: Gaussian 09, Ambertool(14)
# Custom: g09/ambertool path; Whether G09 Rev.B/C ; Gaussian input parameters

if [ -z $1 ];then
echo "Please assign the input file!"
exit
fi

# Parameters for gaussian running
GJFpara="#HF/6-31G* SCF=tight Test Pop=MK iop(6/33=2) iop(6/42=6) iop(6/50=1) opt nosymm"

# If you use G09 Rev B.01, uncomment the following line to fix bug
# G09B01="TRUE"

#Setup the amber/Gaussian environment. You should modify by your own environment
if [ -z $AMBERHOME ];then
source /mnt/home/zhaozx/AmberTools/amber.sh
fi

if [ -z $g09root ];then
source /mnt/home/zhaozx/Software/g09/gau_setup.sh
fi

basename=${1%.*}
exdname=${1##*.}

if [ $exdname = "mol2" ];then
antechamber -fi mol2 -fo gcrt -pf y -i $1  -o ${basename}.gjf -gn "%nproc=8" -gm "%mem=1000MB" -gk "$GJFpara" -ch "${basename}" -gv 1 -ge ${basename}.gesp
elif [ $exdname = "pdb" ];then
antechamber -fi pdb -fo gcrt -pf y -i $1 -o ${basename}.gjf -gn "%nproc=8" -gm "%mem=1000MB" -gk "$GJFpara" -ch "${basename}" -gv 1 -ge ${basename}.gesp
else
echo "Only support for pdb or mol2 files!"
exit
fi

g09 ${basename}.gjf
antechamber -fi gout -fo mol2 -pf y -i ${basename}.log -o ${basename}_esp.mol2 -c esp

# Fix bug in G09 Rev B.01
if [ ! -z $G09B01 ];then
# Generate bugfix tool fixreadinesp.sh developed by Fernando Clemente of Gaussian
# http://ambermd.org/fixreadinesp.sh

if [ ! -f fixreadinesp.sh ];then
echo "#!/bin/bash" > fixreadinesp.sh
echo "if [ \"\$(grep \"Charges from ESP fit\" \${1})\" != \"\" ] ; then" >> fixreadinesp.sh
echo "  printf \"%s\n\" \"\$(grep -i \"%chk=\" \${1})\"" >> fixreadinesp.sh
echo "  printf \"#p geom=allcheck chkbas guess=(read,only) density=check\n\"" >> fixreadinesp.sh
echo "  printf \"nosymm prop=(potential,read) pop=minimal\n\n\"" >> fixreadinesp.sh
echo "  grep \"ESP Fit Center\" \${1} | cut -c32- -" >> fixreadinesp.sh
echo "  printf \"\n\"" >> fixreadinesp.sh
echo "else" >> fixreadinesp.sh
echo "  awk '" >> fixreadinesp.sh
echo "  {" >> fixreadinesp.sh
echo "    if (\$0 ~ /Electric Field/) { " >> fixreadinesp.sh
echo "      while (\$0 !~ /Atom/) { print \$0 ; getline } " >> fixreadinesp.sh
echo "      while (\$0 ~ /Atom/) { print \$0 ; getline }" >> fixreadinesp.sh
echo "      while (\$0 !~ /^ ------/) {" >> fixreadinesp.sh
echo "        CENTERID=\$1" >> fixreadinesp.sh
echo "        OLDSTR=sprintf(\"%s    \",CENTERID)" >> fixreadinesp.sh
echo "        NEWSTR=sprintf(\"%s Fit\",CENTERID)" >> fixreadinesp.sh
echo "        sub(OLDSTR,NEWSTR,\$0)" >> fixreadinesp.sh
echo "        print \$0" >> fixreadinesp.sh
echo "        getline" >> fixreadinesp.sh
echo "        }" >> fixreadinesp.sh
echo "      }" >> fixreadinesp.sh
echo "    sub(/Read-in Center/,\"ESP Fit Center\",\$0)" >> fixreadinesp.sh
echo "    print \$0" >> fixreadinesp.sh
echo "  }' \${1}" >> fixreadinesp.sh
echo "  fi" >> fixreadinesp.sh
chmod +x fixreadinesp.sh
fi

./fixreadinesp.sh ${basename}.log > tmpesp.gjf
g09 tmpesp.gjf
./fixreadinesp.sh tmpesp.log > ${basename}.out
antechamber -fi gout -fo mol2 -pf y -i ${basename}.out -o ${basename}_resp.mol2 -c resp
rm punch qout QOUT esout tmpesp.gjf tmpesp.log

else
# G09 Rev C01/D01
antechamber -fi gesp -fo mol2 -pf y -i ${basename}.gesp -o ${basename}_resp.mol2 -c resp
rm punch qout QOUT esout 

fi # End different Version for resp
echo "Done for $basename!"
