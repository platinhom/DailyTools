#! /bin/bash
# File: mol22pqr.sh
# Author: Zhixiong Zhao, Last Updated: 2015.10
#
# Change the input molecule to pqr file with vdw radius.
# Input: molecule file in pdb/mol2/mpdb/pqr/ac format
# Usage: ./mol22pqr.sh input.mol2 bcc mbondi
# Need: ambertools
# Custom: $AMBERHOME enviroment

if [ -z $1 ];then
echo "Please assign the input file!"
exit
fi

chargetype=$2
if [[ -z $2 || ( $2 != "bcc" && $2 != "mul" && $2 != "gas" && $2 != "no" ) ]];then
echo "Please assign the charge method! Can be:"
echo "  no:  Not to change the charges"
echo "  bcc: for AM1-BCC charge"
echo "  mul: for Mulliken charge"
echo "  gas: for Gasteiger charge"
echo "  cm1, cm2, esp, resp charge need more programs.. so don't support here."
echo "  Now using no charge or origin charge...."
chargetype=no
fi

#vdw Type as: bondi, mbondi(default), mbondi2, mbondi3, amber6.(In amber14)
vdwtype=$3
if [[ -z $3 || ( $3 != "bondi" && $3 != "mbondi" && $3 != "mbondi2" && $3 != "mbondi3" && $3 != "amber6" ) ]];then
echo "Please assign the vdw radius type of atom! Can be:"
echo "  bondi, mbondi(default), mbondi2, mbondi3, amber6.(In amber14)"
echo "  Using default mbondi...."
vdwtype=mbondi
fi

#If need changevdw, change value to "True". And change the vdwtype value
#You can change it to any other string to deactivate it.
changevdw="True"

if [ $changevdw = "True" ];then
	echo "It will use $chargetype method for partial charge and $vdwtype method for vdw radiis."
else 
	echo "It will use $chargetype method for partial charge."
fi

#Setup the amber environment. You should modify by your own environment
if [ -z $AMBERHOME ];then
source /mnt/home/zhaozx/AmberTools/amber.sh

##if you are in HPCC
#module swap GNU Intel/13.0.1.117; module load OpenMPI/1.4.4; module load Amber/14v19;

fi

basename=${1%.*}
exdname=${1##*.}

if [ $chargetype = "no" ];then # No need to change charges

if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
antechamber -fi mol2 -fo mol2 -pf y -i $1 -o ${basename}_gaff.mol2
elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
antechamber -fi mpdb -fo mol2 -pf y -i $1 -o ${basename}_gaff.mol2
else
echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
exit
fi

else # Need to calculate charges.

if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
antechamber -fi $exdname -fo mol2 -pf y -i $1 -c $chargetype -o ${basename}_gaff.mol2
elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
antechamber -fi mpdb -fo mol2 -pf y -i $1 -c $chargetype -o ${basename}_gaff.mol2
else
echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
exit
fi

fi #Whether change charges

# Using tleap to generate top file
parmchk -i ${basename}_gaff.mol2 -f mol2 -o ${basename}_gaff.frcmod
echo "source leaprc.gaff">>${basename}_gaff.leapin
echo "loadamberparams ${basename}_gaff.frcmod" >>${basename}_gaff.leapin
echo "hom=loadmol2 ${basename}_gaff.mol2">>${basename}_gaff.leapin
echo "set default PBRadii $vdwtype" >> ${basename}_gaff.leapin
echo "saveamberparm hom ${basename}_gaff.top ${basename}_gaff.crd">>${basename}_gaff.leapin
echo "quit">>${basename}_gaff.leapin
tleap -f ${basename}_gaff.leapin >/dev/null

# Change the vdw radius by amber sets by parmed.py
# Old version, now it use leap 'set default PBRadii type' instead.
####
#if [ $changevdw = "Truee" ];then
#echo "changeRadii $vdwtype">>${basename}_gaff.parmedin
#echo "outparm ${basename}_gaff.top">>${basename}_gaff.parmedin
#parmed.py -p ${basename}_gaff.top -i ${basename}_gaff.parmedin -O > /dev/null
#fi
####

# Use ambpdb to convert amber input to pqr.
ambpdb -p ${basename}_gaff.top -pqr < ${basename}_gaff.crd >${basename}.pqr
rm ${basename}_gaff.* leap.log
