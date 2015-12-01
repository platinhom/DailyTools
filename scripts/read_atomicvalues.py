#! /usr/bin/env python
# -*- coding: utf8 -*-
# 

__author__="Zhixiong Zhao"
__date__="2015-11-30"
__doc__=""" A script to extract the atomic based data to pqr file. 
You can define new function as read_atomicSingleValue(filename) to define how to read the data file.
And then define a new jobtype in writejob(fname, jobtype=0, jobname=None) function. 
write_pqrx(filename,fout=None,atomvalues=None,keys=None) help to combine the pqr and data to a pqrx file."""

import os,sys
from optparse import OptionParser 

def read_atomicSingleValue(filename):
	# read the data for atoms
	# return a list of data based on atoms sequence
	# Datafile: One data in a line for corresponding atom.
	try:
		SingleValues=[];
		fr=open(filename)
		for line in fr:
			tmp=line.strip().split()
			if (len(tmp)>0):
				SingleValues.append(float(tmp[0]));
		fr.close()
		return SingleValues
	except IOError as e:
		print "Can't find the file "+filename+" since: "+str(e)
		return None
	except ValueError as e:
		print "Value error for file: "+filename+" since: "+str(e)
		fr.close()
		return None	

def read_multipole(filename):
	# read the multipole data (Bao Wang *.mda) for atoms
	# Return (total_dipole, total_quadrupole, dipoles_list, quadrupoles_list) based on atoms sequence
	# Datafile: First line " Atomic Multipole Dipole, Quadrapole moment:"
	#     Then: atomic_dipole atomic_quadrupole for each atom
	#     Then: " Total Dipole, Quadrapole moment Refer to 0: "
	#     Then: total_dopole total_quadrupole
	try:
		fr=open(filename)
		finddata=False
		findtotal=False
		dipoles=[]
		qupoles=[]
		moldipole=0.0
		molqupole=0.0
		for line in fr:
			tmp=line.strip().split()
			if (findtotal):
				moldipole=float(tmp[0])
				molqupole=float(tmp[1])
				findtotal=False;
				break;
			if (tmp[0]=="Total"):
				finddata=False;
				findtotal=True;
				continue;
			if (finddata):
				dipoles.append(float(tmp[0]))
				qupoles.append(float(tmp[1]))
				continue;
			if (tmp[0]=="Atomic"):
				finddata=True;
				continue;
		fr.close()
		return moldipole,molqupole,dipoles,qupoles
	except IOError as e:
		print "Can't find the file "+filename+" since: "+str(e)
		return None

def write_pqrx(filename,fout=None,atomvalues=None,keys=None):
	# Combine a pqr(filename) and given data in a list(atomvalues) based on atomic sequence
	# fout is the output file name
	# keys is Some information to be written in REMARK part. Such as total_dipole: value pair.
	# It's the *Key* function to write out pqrx file
	try:
		if (not atomvalues):
			print "Empty values for atoms!"
			return False
		fr=open(filename)
		fnamelist=os.path.splitext(filename)
		if (not fout):
			fout=fnamelist[0]+".pqrx"
		fw=open(fout,'w')
		if (isinstance(keys,dict)):
			for key,value in keys.items():
				fw.write('REMARK  '+key+'  '+str(value)+'\n');
		count=0
		for line in fr:
			if (line[:4]=='ATOM' or line[:6]=='HETATM'):
				newline=line.strip('\n')+'%12.6f' % atomvalues[count]+'\n';
				fw.write(newline);
				count+=1;
			else:
				fw.write(line);
		fr.close();
		fw.close();
		return True;
	except Exception as e:
		print "Can't successfully deal with file: "+fout+": "+str(e);
		fr.close();fw.close();
		return False;

def writejob(fname, jobtype=0, jobname=None):
	# Define how to deal with your data file and output it
	# You can set new function to process your data file! and be loaded here! 
	# fname is datafile to be read. such as 1ajj.data (for 1ajj.pqr, same prefix)
	# jobtype:
	#	 0: a file saving value at each line
	#	 1: a file saving multipoles informations
	# Jobname: Middle name in output file
	fnamelist=os.path.splitext(fname)

	if (jobtype==0):
		results=read_atomicSingleValue(fname)
		if (jobname): 
			jobname="_"+jobname;
		else:
			jobname=""
		if (not results is None):
			return write_pqrx(fnamelist[0]+".pqr",fout=fnamelist[0]+jobname+".pqrx",atomvalues=results)

	elif (jobtype==1):
		results=read_multipole(fname);
		if (not results is None):
			write_pqrx(fnamelist[0]+".pqr",fout=fnamelist[0]+"_dipole.pqrx",atomvalues=results[2], keys={"DIPOLE":results[0]})
			return write_pqrx(fnamelist[0]+".pqr",fout=fnamelist[0]+"_qupole.pqrx",atomvalues=results[3], keys={"QUPOLE":results[1]})

	else:
		print "Unrecognized job type: "+str(jobtype);
	return False

if (__name__ == '__main__'):
	helpdes="""To read value for atom in pqr and finally generate pqrx file"""
	parser = OptionParser(description=helpdes) 
	parser.add_option("-i", "--input", action="store", 
                    dest="input", default="",
                    help="Read input data from input file")
	parser.add_option("-m", "--multi", action="store", 
					dest="multi", default="",
              		help="File containing file name without extension, format must be assigned!")
	parser.add_option("-f", "--format", action="store", 
					dest="format", default="",
              		help="Input file format (file extension)")
	parser.add_option("-j", "--job", action="store", 
					dest="jobtype", default="0",
              		help="The job type, default 0 for one value per line.")
	parser.add_option("-o", "--outfix", action="store", 
					dest="outfix", default=None,
              		help="The middle name for the output file.")
	(options, args) = parser.parse_args()

	if (len(sys.argv)<2):
		print "Please assign a calculated result file!"
		parser.print_help()
		#parser.print_description()
		#parser.print_usage()
		exit()

	# a file saving id (for id.pqr and id.data) and process all the id-based files!
	# test.py -m id.txt -format data -j jobid [-o dataname]
	if (options.multi !=""):
		if (options.format==""):
			print "Using multifile mode. But input format (extension) is not giving!"
			exit(1)
		fm=open(options.multi)
		for line in fm:
			tmp=line.strip().split()
			if (len(tmp)>0):
				fname=tmp[0]+"."+options.format;
				writejob(fname,int(options.jobtype),options.outfix);
		fm.close()
	# Single file to be process.
	# test.py -i id.txt -j jobid [-o dataname]
	elif (options.input != ""):
		fname=options.input;
		writejob(fname,int(options.jobtype),options.outfix);

		