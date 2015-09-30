#! /bin/bash

curpath=`pwd`
cd /c/Users/Hom/Desktop/MyGit/platinhom/

for dir in HomPDF MolShow platinhom.github.com
do
	cd $dir
	echo ${dir} submitting..
	./gitsubmit.sh
	cd ..
done

cd "$curpath"
