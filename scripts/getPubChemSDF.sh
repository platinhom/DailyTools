#! /bin/bash
# $1: file contains Pubchem Compound ID (one number a line)
NewDir=20150909-628
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


