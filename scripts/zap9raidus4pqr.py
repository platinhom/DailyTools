#! /usr/bin/env python
# -*- coding: utf8 -*-
# Author: Platinhom; Last Updated: 2015-09-09

# Replace the radius of atom by ZAP9 strategy
# Only for pqr format.
# python zap9radius4pqr.py file.pqr

import os,sys

if (__name__ == '__main__'):
	fname=sys.argv[1]
	fnamelist=os.path.splitext(fname)
	fwname=fnamelist[0]+"_zap"+fnamelist[1]
	fr=open(fname)
	fw=open(fwname,'w')

	for line in fr:
		if (line[:4]=="ATOM" or line[:6]=="HETATM"):
			tmp=line.split();
			element=tmp[-1].upper();
			radius="   0.000";
			if (element=='H'):
				radius="   1.100";
			elif (element=='C'):
				radius="   1.870";
			elif (element=='N'):
				radius="   1.400";
			elif (element=='O'):
				radius="   1.760";
			elif (element=='F'):
				radius="   2.400";
			elif (element=='S'):
				radius="   2.150";
			elif (element=='CL'):
				radius="   1.820";
			newline=line[:62]+radius+line[70:];
			fw.write(newline);
		else:
			fw.write(line);
			
	fr.close()
	fw.close()
#end main			
