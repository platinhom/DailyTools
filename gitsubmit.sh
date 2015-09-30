#! /bin/bash
# file: gitsubmit.sh

git add -A
git commit -am "regular"
#if [ ! -z $1 ];then
	#git remote add gitcafe git@gitcafe.com:platinhom/platinhom.git 
	#git push gitcafe master:gitcafe-pages
#fi
git push origin gh-pages
