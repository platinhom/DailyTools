#! /bin/bash
# file: getlink.sh
# Author: Platinhom
# Last updated:2015.11.30

# To list all the pdf file in current directory into the index.md file.
# Notice the encoding problem. http://platinhom.github.io/2015/06/09/msys-utf8-problem/

pd=`pwd`

echo "---
title: PDF
layout: page
comments: yes
---

## ${pd##*HomPDF/}

">index.md

for pdffile in `ls *.pdf`
do
	echo "- [${pdffile}](./$pdffile)">>index.md

done

## replace the gbk encoding file.
if [ ! -z "`file index.md|grep ISO-8859`" ];then
	iconv -f GBK -t UTF-8 index.md > index-2.md
	rm index.md
	mv index-2.md index.md
fi
