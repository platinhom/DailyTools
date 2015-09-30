#! /usr/bin/env python
# -*- coding: utf8 -*-
# Author: Platinhom; Last Updated: 2015-09-30

# Usage: ExtractXYZR from PQR file.
# Only for pqr format now.
# python ExtractXYZR.py file.pqr

import os,sys

supportFormat=[".pqr",]

if (__name__ == '__main__'):
	if (len(sys.argv)!=2):
		print "Give the input file!"
		exit()
	fname=sys.argv[1]
	fnamelist=os.path.splitext(fname)
	if (fnamelist[1]==".xyzr"):
		print "Input file is xyzr format! Exit!"
		exit()
	if (not fnamelist[1].lower() in supportFormat):
		print fnamelist[1][1:]+" format can't be supported now.."
		exit() 
	fxyzr=open(fnamelist[0]+".xyzr",'w')
	fr=open(fname)
	inlines=fr.readlines();
	fr.close();

	# Write out the corresponding xyzr file.
	for line in inlines:
		# Each atom
		if (line[:4]=="ATOM" or line[:6]=="HETATM"):
			# Extract x, y, z, r from pqr to xyzr file
			radius="%10.5f" % float(line[62:70].strip());
			xcoor="%10.5f" % float(line[30:38].strip());
			ycoor="%10.5f" % float(line[38:46].strip());
			zcoor="%10.5f" % float(line[46:54].strip());
			xyzrstr=xcoor+ycoor+zcoor+radius+"\n";
			fxyzr.write(xyzrstr);
	fxyzr.close()
	
#end main			
