import os
import re

def writeLine(fs, line):
	print "write: %s"%line
	fs.write(line)

def fixFile(filePath):
	fs = open(filePath, "r")
	lines = fs.readlines()
	fs.close()

	fs = open(filePath, "w")
	for line in lines:
		result = re.search(r"(?<=\[NSThread\ssleepForTimeInterval:).*(?=\])", line)
		if not result:
			writeLine(fs, line)
			continue

		if line.startswith("\\\\"):
			writeLine(fs, line)
			continue

		time = result.group(0)
		indent = re.search(r"^\s*", line).group(0)
		newLine = indent + "AppeckerWait(" + time + ");";
		writeLine(fs, newLine)
	fs.close()

def onFileDetected( arg, dirname, names ):
	for name in names:
		if re.search(r'\.mm$', name.lower()):
			fixFile(dirname + '/' + name)


os.path.walk(".", onFileDetected, ())
