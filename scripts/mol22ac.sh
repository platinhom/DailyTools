#! /bin/bash
# File: mol22ac.sh
# Author: Zhixiong Zhao, Last Updated: 2015.10.1
#
# Change the input molecule to antechamber ac file with atom type.
# Simplify from mol22pqr.sh, don't need leap/ambpdb any more.
# Input: molecule file in pdb/mol2 format
# Usage: ./mol22ac.sh input.mol2 bcc gaff
# Need: ambertools
# Custom: $AMBERHOME enviroment

#Setup the amber environment. You should modify by your own environment
if [ -z $AMBERHOME ];then
source /mnt/home/zhaozx/AmberTools/amber.sh
fi

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

echo "It will use $chargetype method for partial charge and $atomtype method for atom type."

basename=${1%.*}
exdname=${1##*.}

if [ $chargetype = "no" ];then # No need to change charges

if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
antechamber -fi mol2 -fo ac -pf y -i $1 -at $atomtype -o ${basename}.ac
elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
antechamber -fi mpdb -fo ac -pf y -i $1 -at $atomtype -o ${basename}.ac
else
echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
exit
fi

else # Need to calculate charges.

if [[ $exdname = "mol2" || $exdname = "pdb" || $exdname = "ac" ]];then
antechamber -fi $exdname -fo ac -pf y -i $1 -at $atomtype -c $chargetype -o ${basename}.ac
elif [[ $exdname = "mpdb" || $exdname = "pqr" ]];then
antechamber -fi mpdb -fo ac -pf y -i $1 -at $atomtype -c $chargetype -o ${basename}.ac
else
echo "Only support for pdb/mol2/mpdb/pqr/ac files!"
exit
fi

fi #Whether change charges
