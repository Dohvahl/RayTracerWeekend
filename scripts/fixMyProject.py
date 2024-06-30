#!/usr/bin/env python3
import fileinput
import os
import sys


def getAllFilesWithExtension(ext):
	files = []
	files += [f for f in os.listdir() if f.endswith(ext)]
	files += [os.path.join("cmake", f)
			  for f in os.listdir("./cmake") if f.endswith(ext)]
	files = [os.path.join(".", f) for f in files]
	return files


def getAllCMakeFiles():
	cmakeFiles = []
	cmakeFiles += [f for f in os.listdir() if f.lower().endswith("cmakelists.txt")]
	cmakeFiles += [os.path.join("src", f) for f in os.listdir("./src") if f.lower().endswith("cmakelists.txt")]
	cmakeFiles = [os.path.join(".", f) for f in cmakeFiles]
	cmakeFiles += getAllFilesWithExtension(".cmake")
	return cmakeFiles


def restoreBak():
	bakFiles = getAllFilesWithExtension(".bak")
	for file in bakFiles:
		origFileName = file.removesuffix(".bak")
		print(f"Orig to Remove: {origFileName}\nBackup to Restore: {file}")
		if os.path.exists(origFileName) and os.path.exists(file):
			os.remove(origFileName)
		os.rename(file, origFileName)


def cleaupBak():
	bakFiles = getAllFilesWithExtension(".bak")
	for file in bakFiles:
		if os.path.exists(file):
			os.remove(file)


def fixup(confirmed = False):
	projectName = input("Name of Project: ")
	nameToReplace = input("Name to Replace: ")
	for cmakeFile in getAllCMakeFiles():
		if not confirmed:
			print(cmakeFile)
		else:
			with fileinput.FileInput(cmakeFile, inplace=True, backup='.bak') as file:
				for line in file:
					print(line.replace(nameToReplace, projectName), end='')


if __name__ == "__main__":
	if len(sys.argv) > 1:
		if sys.argv[1] == "--restore":
			restoreBak()
		elif sys.argv[1] == "--cleanup":
			cleaupBak()
		elif sys.argv[1] == "-c":
			fixup(True)
		else:
			pass
	else:
		fixup()