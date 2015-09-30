#! /bin/bash


for dir in HomPDF MolShow platinhom.github.com
do
	cd $dir
	echo ${dir} submitting..
	./gitsubmit.sh
	cd ..
done

