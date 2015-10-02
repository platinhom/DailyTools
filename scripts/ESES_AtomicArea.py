#! /usr/bin/env python
# -*- coding: utf8 -*-
# Author: Platinhom; Last Updated: 2015-10-1

# Summary each atom type surface area from the pqrta file.
# Usage: python ESES_AtomicArea.py file.pqrta gaff
#
# Note: Only for PQRTA format input.
# Custom: ESES parameters, atom type set

import os,sys

# Modify the ESES program parameter here. 
# You can modify to command line input parameter as you like
probe=1.4
grid=0.2
solbuffer=4.0

# 5 sets of atom type
gaff=["br", "c", "c1", "c2", "c3", "ca", "cc", "cd", "ce", "cf", "cg", "cl", "cp", "cx", "cy", "f", "h1", "h2", "h3", "h4", "h5", "ha", "hc", "hn", "ho", "hs", "i", "n", "n1", "n2", "n3", "na", "nb", "nc", "nd", "ne", "nf", "nh", "no", "o", "oh", "os", "p5", "s", "s4", "s6", "sh", "ss", "sy"]

amber=["Br", "C", "C*", "CA", "CB", "CD", "CK", "Cl", "CM", "CN", "CQ", "CR", "CT", "CV", "CW", "CZ", "DU", "F", "H", "H1", "H2", "H3", "H4", "H5", "HA", "HC", "HO", "HS", "I", "N", "N*", "N1", "N2", "NA", "NB", "NC", "NO", "NT", "O", "O2", "OH", "OS", "OW", "P", "S", "SH", "SO"]

sybyl=["Br", "C.1", "C.2", "C.3", "C.ar", "Cl", "F", "H", "I", "N.1", "N.2", "N.3", "N.am", "N.ar", "N.pl3", "O.2", "O.3", "P.3", "S.2", "S.3", "S.o", "S.o2"]

bcc=["11", "12", "13", "14", "15", "16", "17", "21", "22", "23", "24", "25", "31", "32", "33", "42", "51", "52", "53", "71", "72", "73", "74", "91"]

gas=["br", "c1", "c2", "c3", "cl", "f", "h", "i", "n1", "n2", "n3", "na", "o2", "o3", "os", "p", "s2", "s3", "so", "so2"]

if (__name__ == '__main__'):
	fname=sys.argv[1]
	fnamelist=os.path.splitext(fname)
	if (fnamelist[1].lower()!='.pqrta'):
		print 'Input should be pqrta format!'
		exit(1)
	fnum=fnamelist[0].split('_')[0];
	settype=[]
	if (sys.argv[2].lower()=='gaff'):settype=gaff
	elif (sys.argv[2].lower()=='amber'):settype=amber
	elif (sys.argv[2].lower()=='sybyl'):settype=sybyl
	elif (sys.argv[2].lower()=='bcc'):settype=bcc
	elif (sys.argv[2].lower()=='gas'):settype=gas
	else:
		print 'Atom type set should be given, gaff, amber, sybyl, bcc or gas!'
		exit(1)
	areatype={}
	for t in settype:
		areatype[t]=0.0
	fr=open(fname)

	for line in fr:
		# Each atom
		if (line[:4]=="ATOM" or line[:6]=="HETATM"):
			tmp=line.split();
			atype=tmp[-2].strip();
			aarea=float(tmp[-1].strip());
			if (atype not in settype): settype.append(atype);
			areatype[atype]=areatype.setdefault(atype,0.0)+aarea;
	fr.close()

	outputatype=fnum+' '
	outputaarea=fnum+' '
	for atype in settype:
		outputatype=outputatype+atype+' '
		outputaarea=outputaarea+str(areatype[atype])+" ";
	print outputatype+' : '+outputaarea;

#end main			
