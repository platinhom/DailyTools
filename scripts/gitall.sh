#! /bin/bash --login
# Author: Hom 2015.10.13
# Use for submit/pull for github

# Need set up: MYGIT_PATH, MYGIT_ALL

nowpwd=`pwd`
action=$1
if [ -z $1 ];then
	action='p'
fi
action=`echo $action | tr 'A-Z' 'a-z'`

if [[ ! ($action == "p" || $action == "s") ]];then
	echo "Action don't know: should be s (submit) or p (pull)"
	exit 1
fi

if [ ! -z $MYGIT_PATH ];then
	cd $MYGIT_PATH

	if [ ! -z "$MYGIT_ALL" ];then
		for dir in $MYGIT_ALL
			do
			cd $dir
			if [ $action = "s" ];then
				echo ${dir} submitting..
				./gitsubmit.sh
			else 
				echo ${dir} pulling....
				git pull
			fi
			cd ..
			done
	else
	    echo "MYGIT_ALL should be set to project folder name as A B C D"
	fi
	
	cd $nowpwd
fi
