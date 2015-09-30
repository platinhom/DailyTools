#! /bin/bash
#
# File: getPubChemSDF.sh
# Author: Hom, 2015.9.30
# Get the Pubchem compounds in 3D-sdf format by cid saved in a file.
#
# Usage: ./getPubChemSDF.sh cid.txt 
# 	$1: file contains Pubchem Compound ID (one number a line)

NewDir=GETCOMPOUNDS
mkdir $NewDir

for fil in `cat $1`
do
if [ ! -f ${fil}.sdf ];then
	dat="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${fil}/record/SDF/?response_type=save&record_type=3d"
	wget $dat -O ${fil}.sdf
	mv ${fil}.sdf $NewDir
else
	mv ${fil}.sdf $NewDir
fi
done


