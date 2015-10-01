#! /bin/bash

nowdir=`pwd`
cd ~/MyGit

for dir in DailyTools HomPDF MolShow platinhom.github.com
do
	cd $dir
	echo ${dir} submitting..
	./gitsubmit.sh
	cd ..
done

cd $nowdir

