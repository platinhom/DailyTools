#! /bin/bash


for dir in DailyTools HomPDF MolShow platinhom.github.com
do
	cd $dir
	echo ${dir} pulling..
	git pull
	cd ..
done
