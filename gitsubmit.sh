#! /bin/bash
# file: gitsubmit.sh

comment=$1       
                 
if [ -z $1 ];then
comment="regular"
fi

git add -A
git commit -am "$comment"
#if [ ! -z $2 ];then
	#git remote add gitcafe git@gitcafe.com:platinhom/platinhom.git 
	#git push gitcafe master:gitcafe-pages
#fi
# maybe you should revise this for your branch
git push origin gh-pages
