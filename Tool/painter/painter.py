	
# If you have any questions, please contact williammu@tencent.com

from Tkinter import *
from tkSimpleDialog import *
import re



class CodeWindow( Frame ):
	def __init__( self, parent, codeStr,  **kwArgs ):
		Frame.__init__( self, parent, kwArgs )
		self.createTextArea( codeStr )
	
	def createTextArea( self, codeStr ):
		frame = Frame( self )
		frame.pack( expand = YES, fill = BOTH )
		text = Text( frame )
		print codeStr
		text.insert( "1.0", codeStr )
		text.pack( expand = YES, fill = BOTH )
		text.tag_add( SEL, "1.0", END + "-1c" )
		text.focus_set()
		
		



class PaintWindow( Frame ):
	def __init__( self, parent, **kwArgs ):
		Frame.__init__( self, parent, kwArgs )
		self.canvas = None
		self.createCanvasAndStatus()
		self.id2Data = {}
		self.curItemID = -1
		self.hScrollBar = None
		self.vScrollBar = None

	def onFindControl( self, event ):
		frameStr = askstring( "Find a control:", "Frame:", parent = self )
		if not frameStr:
		       	self.canvas.focus_set()
			return

		frame = eval( frameStr )
		
		for key,val in self.id2Data.iteritems():
			if val.frame == frame:
				self.setSelected( key )
				break
		self.canvas.focus_set()
		
	def createCanvasAndStatus( self ):
		frame = Frame( self )
		frame.pack( expand = YES, fill = BOTH )
		canvas = Canvas( frame, takefocus = True, borderwidth = 0, highlightthickness = 0 )
		self.canvas = canvas
		canvas.bind( "<Control-f>", self.onFindControl )
		
		self.addScrollBar( frame )
		canvas.pack( expand = YES, fill = BOTH )

		entry = Entry( frame )
		entry.pack( fill = BOTH, side = BOTTOM )
		entry.bind( "<Control-f>", self.onFindControl )
		self.status = entry

		canvas.focus_set()
		
	
	def drawRect( self, oriX, oriY, width, height):
		print oriX,oriY,width,height
		offset = 50
		return self.canvas.create_rectangle( oriX + offset , \
				oriY + offset, \
				oriX + width + offset, \
				oriY + height + offset, \
				outline = 'black' )

	def setStatus( self, statusText ):
		self.status.delete( 0, END )
		self.status.insert( 0, statusText )

	def setSelected( self, id ):
		if self.curItemID != -1:
			self.canvas.itemconfig( self.curItemID, outline = 'black' )
		self.canvas.itemconfig( id, outline = 'red' )
		self.canvas.tkraise( id )
		self.setStatus( self.id2Data.get( id ).description )
		self.curItemID = id	

	def onRectClick( self, event, id ):
		print "%s clicked !"%id
		self.setSelected( id )
	
	def generateLocatingCode( self ):
		dataObj = self.id2Data.get( self.curItemID )
		frameStr = re.findall( '\d+,\s\d+,\s\d+,\s\d+', dataObj.description )[0]
		codeStr = "CGRect frame = CGRectMake(%s);\n"%frameStr
		codeStr += "id target = [[UIWindow mainWindow] LocateViewByFrame:frame bias:3];\n"
		codeStr += "if(!target){\n"
		codeStr += "	ATLogErrorFormat(@\"Locating error: %@::%@\", NSStringFromClass([self class]) ,NSStringFromSelector(_cmd));\n"
		codeStr += "}\n"
		codeStr += "return target;\n"
		return codeStr

	def showCodeWindow( self, codeStr ):
		top = Toplevel()
		top.geometry( "800x600+60+60" )
		CodeWindow( top, codeStr ).pack( expand = YES, fill = BOTH )

	def onRectDoubleClick( self, event, id ):
		self.onRectClick( event, id )
		code = self.generateLocatingCode()
		self.showCodeWindow( code )

	def getCanvasRange( self ):
		sampleObj = self.id2Data.values()[0]
		xMin = sampleObj.frame[0]
		yMin = sampleObj.frame[1]
		wMax = sampleObj.frame[2]
		hMax = sampleObj.frame[3]
		for rectID in self.id2Data:
			dataObj = self.id2Data[ rectID ]	
			frame = dataObj.frame
			xMin = frame[0] if frame[0] < xMin else xMin
			yMin = frame[1] if frame[1] < yMin else yMin
			wMax = frame[2] if frame[2] > wMax else wMax
			hMax = frame[3] if frame[3] > hMax else hMax
		return (xMin, yMin, wMax, hMax)

	def addScrollBar( self, frame ):
		self.hScrollBar = Scrollbar( frame, orient = 'horizontal' )
		hbar = self.hScrollBar
		hbar.config( command = self.canvas.xview )
		
		self.vScrollBar = Scrollbar( frame )
		vbar = self.vScrollBar
		vbar.config( command = self.canvas.yview )

		hbar.pack(side = BOTTOM, fill = X)
		vbar.pack(side = RIGHT, fill = Y)

		self.canvas.config( yscrollcommand = vbar.set )
		self.canvas.config( xscrollcommand = hbar.set )
	
	def updateScrollRegion( self ):
		region = self.getCanvasRange()
		self.canvas.config( scrollregion = region )

	def drawAllRect( self, dataSet ):
		for dataObj in dataSet:
			rectID = self.drawRect( *dataObj.frame )	
			self.canvas.tag_bind( rectID,  '<ButtonPress>' ,lambda event, x = rectID: self.onRectClick( event, x ) )
			self.canvas.tag_bind( rectID, '<Double-Button-1>', lambda event, x = rectID: self.onRectDoubleClick( event, x ) )
			self.id2Data[ rectID ] = dataObj
		self.updateScrollRegion()

class DataObject:
	def __init__( self, str ):
		str = str.strip()
		self.description = str
		assert str.find( 'frame =' ) != -1, "Can't locate frame data: %s"%str
		frameStr = re.findall( '\{frame\s=\s.+\}', str )[0]
		exec( frameStr[1:-1] )	
		self.frame = frame

class MainWindow( Frame ):
	def __init__( self, parent, **kwArgs ):
		Frame.__init__( self, parent, kwArgs )
		self.createControlArea()
	
	def createControlArea( self ):
		frame = Frame( self )
		frame.pack( expand = YES, fill = BOTH )
		
		text = Text( frame )
		text.pack( expand = YES, fill = BOTH )
		self.text = text

		text.bind( '<Control-c>', self.clearText )
		text.bind( '<Control-d>', self.onDraw )

		button = Button( frame, text = 'Draw!', command = self.onDraw )
		button.pack( side = BOTTOM )

	def createPaintWindow( self ):
		top = Toplevel( )
		top.geometry( '1024x768+40+40' )
		paintWindow = PaintWindow( top )
		self.doPaint( paintWindow )
		paintWindow.pack( fill = BOTH, expand = YES )
	
	def clearText( self, event ):
		self.text.delete( '1.0', END )

	def doPaint( self, paintWindow ):
		allText = self.text.get( '1.0', END + '-1c' )
		
		lines = allText.split('\n')
		allRectData = []
		for line in lines:
			if not len( line ): continue
			allRectData.append( DataObject( line ) )
		
		paintWindow.drawAllRect( allRectData )

		

	def onDraw( self, event = None ):
		self.createPaintWindow()

		
		



if __name__ == '__main__':
	root = Tk()
       	root.geometry( '1024x768+20+20')	
	root.title( "Appecker Painter v0.1" )
	MainWindow( root ).pack( expand = YES, fill = BOTH )

	mainloop()
