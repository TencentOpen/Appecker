#coding=utf8

import sys
import codecs
import xml.etree.ElementTree
import os

#Error Type:
INVALID_LOG_FILE = 1

FAILED_CASE_DETAIL_PATH = "FailedCaseDetail.html"
RUN_RESULT_PATH = "RunResult.html"
ALL_CASE_LIST_PATH = "AllCaseList.html"

reload(sys)
sys.setdefaultencoding("utf8")

class CaseWrapper:
	def __init__( self, caseNode ):
		self.__caseNode = caseNode
		
	def isFailed( self ):
		caseNode = self.__caseNode
		endTestNode = caseNode.find("EndTest")
		assert endTestNode is not None, "No EndTest node found!"

		result = endTestNode.attrib["Result"]
		
		if result == "Fail":
			return True
		return False
	
	def getName( self ):
		caseNode = self.__caseNode
		startTestNode = caseNode.find("StartTest")
		assert startTestNode is not None, "No StartTest node found!"
		caseName = startTestNode.attrib["msg"]
		return caseName
		
	def getAllMsg( self ):
		caseNode = self.__caseNode
		childNodeLst = caseNode.getchildren()
		msgLst = []
		for childNode in childNodeLst:
			if	childNode.tag != "Msg" and \
				childNode.tag != "Error":
				continue
			baseMsg = childNode.attrib["msg"]
			prefix = ""
			if childNode.tag == "Msg":
				prefix = "Msg:"
			else:
				prefix = "Error:"
			msg = prefix + baseMsg
			msgLst.append(msg)
		return msgLst
	

class HtmlBuilder:
	def __init__( self,casesInWrapper ):
		self.__casesInWrapper = casesInWrapper
	
	def buildFailedCaseTable( self ):
		cases = self.__casesInWrapper
		
		header = "<tr>\n<th width=\"90%\">CaseID</th>\n<th width=\"10%\">Result</th>\n</tr>\n"
		
		failedCaseTable = ""
				
		failedCaseTemplate = 	"<tr>\n<td><a href=\"./"+ FAILED_CASE_DETAIL_PATH + "#%s\">%s</a></td>\n<td align=\"center\">%s</td>\n</tr>\n"
		failedCaseCaption = "<caption><b>All Failed Cases</b></caption>"
		
		for wrapper in cases:
			name = wrapper.getName()
			if wrapper.isFailed():
				failedCaseTable += failedCaseTemplate%(name, name, "Failed")
				
		tableTemplate = "<table border=\"1\" width=\"80%%\" align=\"center\">%s\n%s\n%s</table>\n"
				
		failedCaseTable = tableTemplate%(failedCaseCaption, header, failedCaseTable)

		return failedCaseTable
		
	def buildFailedCaseDetail( self ):
		cases = self.__casesInWrapper
		
		template = "<a name=\"%s\"><b>%s</b></a><br><br>\n<pre>%s</pre><hr/>"
		
		failCaseDetail = ""
		
		for wrapper in cases:
			msg = "<br>".join(wrapper.getAllMsg())
			name = wrapper.getName()
			failCaseDetail += template%(name, name, msg)
		
		
		return failCaseDetail
		
	def __getCaseInMap( self ):
		cases = self.__casesInWrapper
		dic = {}
		
		for wrapper in cases:
			name = wrapper.getName()
			className, caseName = name.split(".")
			
			if className not in dic:
				dic[className] = []
			
			dic[className].append(caseName)
			
		return dic
	
	def buildAllCaseTable( self ):
		cases = self.__casesInWrapper
		caption = "<caption><b>All Cases</b></caption>"
		header = "<tr>\n<th width=\"50%\">Class</th>\n<th width=\"50%\">Total</th>\n</tr>\n"
		rowTemplate = 	"<tr>\n<td><a href=\"./"+ ALL_CASE_LIST_PATH + "#%s\">%s</a></td>\n<td align=\"center\">%d</td>\n</tr>\n"
		tableTemplate = "<table border=\"1\" width=\"80%%\" align=\"center\">%s\n%s\n%s</table>\n"
		content = ""
		
		caseInMap = self.__getCaseInMap()
		
		for className,caseNameLst in caseInMap.iteritems():
			content += rowTemplate%(className, className, len(caseNameLst))
		
		return tableTemplate%(caption, header, content)
		
	def __findCaseByID( self, caseID ):
		cases = self.__casesInWrapper
		
		for wrapper in cases:
			if caseID == wrapper.getName():
				return wrapper
		return None
		
	def buildAllCaseList( self ):
		caption = "<caption><b>%s</b></caption>"
		header = "<tr>\n<th width=\"90%\">CaseID</th>\n<th width=\"10%\">Result</th>\n</tr>\n"
		passedRowTemplate = "<tr>\n<td>%s</td>\n<td align=\"center\">%s</td>\n</tr>\n"
		failedRowTemplate = "<tr>\n<td><font color=\"red\">%s</font></td>\n<td align=\"center\"><font color=\"red\">%s</font></td>\n</tr>\n"
		tableTemplate = "<a name=\"%s\"></a><table border=\"1\" width=\"80%%\" align=\"center\">%s\n%s\n%s</table>\n"
		cases = self.__casesInWrapper
		caseInMap = self.__getCaseInMap()
		
		allContent = ""
		
		for className, caseNameLst in caseInMap.iteritems():
			thisCaption = caption%className
			content = ""
			for caseName in caseNameLst:
				wrapper = self.__findCaseByID( className + "." + caseName )
				name = wrapper.getName()
				if wrapper.isFailed():
					content += failedRowTemplate%( name, "Failed" )
				else:
					content += passedRowTemplate%( name, "Passed")
				
			allContent += tableTemplate%(className, thisCaption, header, content)
			allContent += "<br><br>"
		
		return allContent

def errorHandle( errorType ):
	if errorType == INVALID_LOG_FILE:
		print >> sys.stderr, "Invalid log file!"

def getCasesInWrapper( rootNode ):
	testCases = rootNode.findall("Testcase")
	
	cases = []
	for case in testCases:
		cases.append( CaseWrapper(case) )
	return cases
	
	
def generateFailedCaseTable( casesInWrapper ):
	builder = HtmlBuilder(casesInWrapper)
	return builder.buildFailedCaseTable()	

def generateFailedCaseDetail( casesInWrapper ):
	builder = HtmlBuilder( casesInWrapper )
	return builder.buildFailedCaseDetail()
	
def generateAllCaseTable( casesInWrapper ):
	builder = HtmlBuilder( casesInWrapper )
	return builder.buildAllCaseTable()
	
def generateAllCaseList( casesInWrapper ):
	builder = HtmlBuilder( casesInWrapper )
	return builder.buildAllCaseList()

def writeDown( fileName, content ):
	header = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n"
	
	fs = open(fileName, "w")
	fs.write(header)
	fs.write(content)
	fs.close()

def generateLog( path ):
	rootNode = None
	try:
		tree = xml.etree.ElementTree.ElementTree(file=path)
		rootNode = tree.getroot()
			
		if rootNode is None or rootNode.tag != "Root-Logger":
			errorHandle( INVALID_LOG_FILE )
			return
	except:
		print >>sys.stderr,sys.exc_info()[1]
		return
	
	
	casesInWrapper = getCasesInWrapper(rootNode)
	
	failedCaseTable = generateFailedCaseTable( casesInWrapper )
	allCaseTable = generateAllCaseTable( casesInWrapper )
	lineBreak = "<br><br>"
	writeDown(RUN_RESULT_PATH, failedCaseTable + lineBreak + allCaseTable)
	
	failedCaseDetail = generateFailedCaseDetail( casesInWrapper )
	writeDown(FAILED_CASE_DETAIL_PATH, failedCaseDetail)
	
	allCaseList = generateAllCaseList( casesInWrapper )
	writeDown(ALL_CASE_LIST_PATH, allCaseList)


def getPath():
	return "log.xml"

def fixup():
	
	#fix file BOM
	fs = open( "app.log", "rb" )
	strData = fs.read()
	fs.close()
	
	strData = strData.replace( "\xff\xfe", "" )
	fs = open( "log.xml", "wb" )
	fs.write(strData)
	fs.close()
	
	#fix Testcase tag
	fs = open( "log.xml", "rb" )
	strData = fs.read()
	fs.close()
	
	strData = strData.decode("utf-16")
	lines = strData.split("\n")
	
	finalLines = []
	i = 0
	for line in lines:
		if line.find("StartTest t=") != -1:
			finalLines.append("<Testcase id=\"table%d\">"%i)
		elif line.find("</EndTest>") != -1:
			finalLines.append(line)
			finalLines.append("</Testcase>")
			continue
		elif line.find("?xml version=\"1.0\"") != -1:
			finalLines.append(line)
			finalLines.append("<?xml-stylesheet type=\"text/xsl\" href=\"log.xsl\"?>")
			continue
		finalLines.append(line)
		i += 1
	
	fs = open( "log.xml", "wb" )
	strData = "\n".join(finalLines)
	strData = strData.encode("utf-16")
	fs.write(strData)
	fs.close()
	
	
	print "File is fixed up properly!"


if  __name__ == "__main__":
	fixup()
	path = getPath()
	generateLog( path )
	print "All done!"