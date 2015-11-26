#! /bin/bash
#
# File: getPubChemSDF.sh
# Author: Hom, 2015.11.26
# Get the Pubchem compounds in 3D-sdf format by cid saved in a file.
#
# Usage: ./getPubChemSDF.sh cid.txt 
# To get a single file: echo cid | ./getPubChemSDF.sh
# 	$1: file contains Pubchem Compound ID (one number a line)
#   $2: dir name to save result, default '.'

cidlist=`cat $1`
if [ ! -z $2 ];then 
NewDir=$2
[ -d $NewDir ] || mkdir $NewDir
cd $NewDir
fi

for fil in $cidlist
do
if [ ! -f ${fil}.sdf ];then
	dat="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${fil}/record/SDF/?response_type=save&record_type=3d"
	wget $dat -O ${fil}.sdf
fi
done