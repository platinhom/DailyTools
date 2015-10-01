#! /bin/bash
# File: mol22ac.sh
# Author: Zhixiong Zhao, Last Updated: 2015.9.30
#
# Change the input molecule to antechamber ac file with atom type.
# Input: molecule file in pdb/mol2 format
# Usage: ./mol22ac.sh input.mol2 bcc gaff
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
chargetype=no
fi

#atom type as: gaff(default), amber, sybyl, bcc, gas.(In amber14)
atomtype=$3
if [[ -z $3 || ( $3 != "gaff" && $3 != "amber" && $3 != "sybyl" && $3 != "bcc" && $3 != "gas" ) ]];then
echo "Please assign the atom type in molecule! Can be:"
echo "gaff(default), amber, sybyl, bcc, gas.(In amber14)"
echo "Using default gaff...."
atomtype=gaff
fi

#If need changevdw, change value to "True". And change the atomtype value
#You can change it to any other string to deactivate it.
changevdw="True"

if [ $changevdw = "True" ];then
echo "It will use $atomtype method for vdw radiis."
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

if [ $exdname = "mol2" ];then
antechamber -fi mol2 -fo mol2 -pf y -i $1 -o ${basename}_gaff.mol2
elif [ $exdname = "pdb" ];then
antechamber -fi pdb -fo mol2 -pf y -i $1 -o ${basename}_gaff.mol2
else
echo "Only support for pdb or mol2 files!"
exit
fi

else # Need to calculate charges.

if [ $exdname = "mol2" ];then
antechamber -fi mol2 -fo mol2 -pf y -i $1 -c $chargetype -o ${basename}_gaff.mol2
elif [ $exdname = "pdb" ];then
antechamber -fi pdb -fo mol2 -pf y -i $1 -c $chargetype -o ${basename}_gaff.mol2
else
echo "Only support for pdb or mol2 files!"
exit
fi

fi #Whether change charges

parmchk -i ${basename}_gaff.mol2 -f mol2 -o ${basename}_gaff.frcmod
echo "source leaprc.gaff">>${basename}_gaff.leapin
echo "loadamberparams ${basename}_gaff.frcmod" >>${basename}_gaff.leapin
echo "hom=loadmol2 ${basename}_gaff.mol2">>${basename}_gaff.leapin
echo "saveamberparm hom ${basename}_gaff.top ${basename}_gaff.crd">>${basename}_gaff.leapin
echo "quit">>${basename}_gaff.leapin
tleap -f ${basename}_gaff.leapin >/dev/null

#Change the vdw radius by amber sets
####
if [ $changevdw = "True" ];then
echo "changeRadii $atomtype">>${basename}_gaff.parmedin
echo "outparm ${basename}_gaff.top">>${basename}_gaff.parmedin
parmed.py -p ${basename}_gaff.top -i ${basename}_gaff.parmedin -O > /dev/null
fi
####

ambpdb -p ${basename}_gaff.top -pqr < ${basename}_gaff.crd >${basename}.pqr
rm ${basename}_gaff.* leap.log
