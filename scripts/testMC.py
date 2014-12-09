#! /usr/bin/python

import sys
import os
from subprocess import Popen, PIPE

def printHelp(script_name):
	print("Usage: "+script_name+" <text_file>|<-b bin_file>")

def handleBinary(fn):
	print fn

def handleFile(fn):
	# Convert file to a binary file
	print fn

if __name__ == "__main__":
	print sys.argv
	script_name_full = sys.argv[0]
	argc = len(sys.argv)
	if argc == 1:
		printHelp(script_name_full)
		sys.exit(1)
	
	if sys.argv[1] == "-b" and argc == 3:
		handleBinary(sys.argv[2])
	elif argc == 2 and sys.argv[1] != "-b":
		handleFile(sys.argv[1])
	else:
		printHelp(script_name_full)
		sys.exit(2)
	
	process = Popen(['make', 'veryclean', 'sim_full_source'])
	stdout, stderr = process.communicate()
	

	print("Exiting "+script_name_full)
	sys.exit(0)
