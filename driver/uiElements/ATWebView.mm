///////////////////////////////////////////////////////////////////////////////////////////////////////
// Tencent is pleased to support the open source community by making Appecker available.
// 
// Copyright (C) 2015 THL A29 Limited, a Tencent company. All rights reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "ATLogger.h"

#define RETURN_AS_BOOL( resStr )\
	if([(resStr) isEqualToString:@"YES"]) \
		return	YES; \
	return NO;

#define RETURN_AS_INT( resStr )\
	return [(resStr) intValue];

static NSString* s_trimNodeValue = @"function trimNodeValueAtf( nodeValue ){"
	"var maxLen = 100;"
	"var nl = new RegExp('\\\\n', 'gi');"
	"var rt = new RegExp('\\\\r', 'gi');"
	"nodeValue = nodeValue.replace(nl, '');"
	"nodeValue = nodeValue.replace(rt, '');"
	"if(nodeValue.length > maxLen){"
		"nodeValue = nodeValue.substring(0,maxLen);"
		"nodeValue += '...';"
	"}"
	"return nodeValue;"
"}";

static NSString* s_getNodeTypeDesc = @"function getNodeTypeDescAtf( nodeType ){"
	"var typeName = '';"
	"switch( nodeType ){"
		"case 1:"
		"typeName = 'ELEMENT';"
		"break;"

		"case 2:"
		"typeName = 'ATTRIBUTE';"
		"break;"

		"case 3:"
		"typeName = 'TEXT';"
		"break;"

		"case 8:"
		"typeName = 'COMMENTS';"
		"break;"

		"case 9:"
		"typeName = 'DOCUMENT';"
		"break;"

		"default:"
		"typeName = 'UNKNOWN';"
		"break;"
	"}"
	"return typeName;"
"}";

static NSString* s_isInNoFrameList = @"function isInNoFrameListAtf( node ){"
	"var tagName = node.tagName;"
	"if(tagName == 'SCRIPT'){"
		"return true;"
	"} else if(tagName == 'META'){"
		"return true;"
	"} else if(tagName == 'STYLE'){"
		"return true;"
	"} else {"
		"return false;"
	"}"
"}";

static NSString* s_getNodeDesc = @"function getNodeDescAtf( node ){"
	"var desc = '';"
	"if( node.nodeType != null ){"
		"desc += getNodeTypeDescAtf( node.nodeType ) + ' ';"
	"}"

	"if( node.id != null && node.id.length ){"
		"desc += '[id = ' + node.id + ']' + ' ';"
	"}"

	"if( node.nodeName != null && node.nodeName.length ){"
		"desc += '[name = ' + node.nodeName + ']' + ' ';"
	"}"

	"if( node.className != null && node.className.length ){"
		"desc += '[class = ' + node.className + ']' + ' ';"
	"}"

	"if( node.tagName != null && node.tagName.length ){"
		"desc += '[tag = ' + node.tagName + ']' + ' ';"
	"}"

	"if( node.type != null && node.type.length){"
		"desc += '[type = ' + node.type + ']' + ' ';"
	"}"

	"if( node.value != null && node.value.length){"
		"desc += '[value = ' + node.value + ']' + ' ';"
	"}"

	"if( node.nodeValue != null && node.nodeValue.length) {"
		"var trimedVal = trimNodeValueAtf( node.nodeValue );"
		"if(trimedVal.length){"
			"desc += '{value = ' + trimedVal + '}' + ' ';"
		"}"
	"}"

	"if( node.offsetLeft != null && node.offsetTop != null ){"
		"var x = getLeftAtf(node);"
		"var y = getTopAtf(node);"
		"var w = node.offsetWidth;"
		"var h = node.offsetHeight;"
		"if(x || y || w || h ){"
			"desc += '(frame = ' + x + ',' + y + ',' + w + ',' + h + ')' + ' ';"
		"}"
	"}"
	"return desc;"
"}";

static NSString* s_getTree = @"function getTreeAtf( node, depth ){"
//		"if(depth > 10000){"
//			"return '';"
//		"}"
	"var treeStr = '';"
	"var prefix = new Array(depth + 1).join('  ');"
	"var desc = getNodeDescAtf( node );"
	"treeStr = prefix + desc + '\\\\n';"
	"var childCnt = node.childNodes.length;"
	"for( var i = 0; i < childCnt; i ++ ){"
		"n = node.childNodes[i];"
		"treeStr += getTreeAtf( n, depth + 1 );"
	"}"
	"return treeStr;"
"}";

static NSString* s_clickNodeWithClass = @"function clickNodeWithClassAtf(className, idx){"

	"var nodeAry = document.getElementsByClassName(className);"

	"if(idx >= nodeAry.length){"
		"return '';"
	"}"

	"return clickInternalAtf(nodeAry[idx]);"
"}";

static NSString* s_clickNodeWithID = @"function clickNodeWithIDAtf(nodeID){"
	"var node = document.getElementById(nodeID);"
	"if(node == null){"
		"return '';"
	"}"
	"return clickInternalAtf(node);"
"}";

static NSString* s_clickNodeWithValue = @"function clickNodeWithValueAtf(value, idx){"
	"var nodeAry = getNodeWithValueInAryAtf(value);"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"

	"return clickInternalAtf(nodeAry[idx]);"
"}";


static NSString* s_clickInternalAtf = @"function clickInternalAtf(node){"
	"var evt = document.createEvent('HTMLEvents');"
	"evt.initEvent('click', true, false);"

	"node.dispatchEvent(evt);"
	"return 'YES';"
"}";


static NSString* s_getNodeWithClassNum = @"function getNodeWithClassNumAtf(className){"
	"var nodeAry = document.getElementsByClassName(className);"

	"return nodeAry.length;"
"}";


static NSString* s_getNodeWithClassDesc = @"function getNodeWithClassDescAtf(className, idx){"
	"var nodeAry = document.getElementsByClassName(className);"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"
	"return getNodeDescAtf(nodeAry[idx]);"
"}";

static NSString* s_getTop = @"function getTopAtf(node){"
	"var offset = node.offsetTop;"
	"if(node.offsetParent != null) {"
		"offset += getTopAtf(node.offsetParent);"
	"}"
	"return offset;"
"}";

static NSString* s_getLeft = @"function getLeftAtf(node){"
	"var offset = node.offsetLeft;"
	"if(node.offsetParent != null) {"
		"offset += getLeftAtf(node.offsetParent);"
	"}"
	"return offset;"
"}";

static NSString* s_getNodeWithValueInAry = @"function getNodeWithValueInAryAtf(value){"
	"var rootNode = document.documentElement;"
	"var iter = document.createNodeIterator(rootNode, NodeFilter.SHOW_ALL, null, false);"
	"var node;"
	"var nodeAry = new Array();"
	"while(node = iter.nextNode()){"
		"if(node.nodeValue != null && node.nodeValue == value){"
			"nodeAry.push(node);"
		"}"
	"}"
	"return nodeAry;"
"}";


static NSString* s_getNodeWithValueNum = @"function getNodeWithValueNumAtf(value){"
	"var nodeAry = getNodeWithValueInAryAtf(value);"
	"return nodeAry.length;"
"}";


static NSString* s_getNodeWithValueDesc = @"function getNodeWithValueDescAtf(value, idx){"
	"var nodeAry = getNodeWithValueInAryAtf(value);"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"
	"return getNodeDescAtf(nodeAry[idx]);"
"}";


static NSString* s_getNodeWithTagDesc = @"function getNodeWithTagDescAtf(tagName, idx){"
	"var nodeAry = document.getElementsByTagName(tagName);"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"
	"return getNodeDescAtf(nodeAry[idx]);"
"}";


static NSString* s_getNodeWithTagNum = @"function getNodeWithTagNumAtf(tagName){"
	"var nodeAry = document.getElementsByTagName(tagName);"
	"return nodeAry.length"
"}";

static NSString* s_setInputValue = @"function setInputValueAtf(value, idx){"
	"var nodeAry = document.getElementsByTagName('INPUT');"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"
	"nodeAry[idx].value = value;"
	"return 'YES';"
"}";

static NSString* s_clickNodeWithTag = @"function clickNodeWithTagAtf(tagName, idx){"
	"var nodeAry = document.getElementsByTagName(tagName);"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"
	"return clickInternalAtf(nodeAry[idx]);"
"}";

static NSString* s_getNodeAttr = @"function getNodeAttrAtf(tagName, idx, attrName){"
	"var nodeAry = document.getElementsByTagName(tagName);"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"
	"return eval('nodeAry[' + idx + '].' + attrName);"
"}";

static NSString* s_setNodeAttr = @"function setNodeAttrAtf(tagName, idx, attrName, attrValue){"
	"var nodeAry = document.getElementsByTagName(tagName);"
	"if(idx >= nodeAry.length){"
		"return '';"
	"}"
	"return eval('nodeAry[' + idx + '].' + attrName + '=' + attrValue );"
"}";

@implementation UIWebView ( ATWebView )

-(void) printInnerHTML
{
	ATLogMessage([self getInnerHTML]);
}

-(BOOL) isFuncExist:(NSString*) funcName
{
	NSString* funcQueryTemplate = @"typeof(%@);";
	NSString* funcQuery = [NSString stringWithFormat:funcQueryTemplate, funcName];
	NSString* res = [self stringByEvaluatingJavaScriptFromString:funcQuery];
	if([res isEqualToString:@"function"])
		return YES;
	return NO;
}

-(NSString*) getInnerHTML
{
	NSString* innerHTML = [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
	return innerHTML;
}


-(NSString*) getFuncNameFromText:(NSString*) funcText
{
	NSRange range = [funcText rangeOfString:@"("];
	NSString* decl = [funcText substringToIndex:range.location];
	NSArray* components = [decl componentsSeparatedByString:@"function "];
	NSString* name = [components objectAtIndex:1];
	name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return name;
}


-(void) registFunc:(NSString *)funcText
{
	NSString* funcName = [self getFuncNameFromText:funcText];

	BOOL funcExist = [self isFuncExist:funcName];

	if(funcExist) return;

	NSString* funcTemplate = @"var script = document.createElement('script');"
	"script.type = 'text/javascript';"
	"script.text = \"%@\";"
	"document.getElementsByTagName('head')[0].appendChild(script);";

	NSString* funcRegist = [NSString stringWithFormat:funcTemplate, funcText];

	//add this function into DOM
	[self stringByEvaluatingJavaScriptFromString:funcRegist];
}

-(NSString*) callFunc:(NSString*) call
{
	return [self stringByEvaluatingJavaScriptFromString:call];
}


-(NSString*) getDOMTree
{
	[self registFunc:s_trimNodeValue];
	[self registFunc:s_getNodeTypeDesc];
	[self registFunc:s_getNodeDesc];
	[self registFunc:s_getTree];
	[self registFunc:s_getTop];
	[self registFunc:s_getLeft];

	NSString* treeStr = [self callFunc:@"getTreeAtf(document.documentElement, 1);"];

	return treeStr;
}

-(void) printDOMTree
{
	ATLogMessage([self getDOMTree]);
}

-(BOOL) clickNodeWithClass:(NSString*) className
{
	[self clickNodeWithClass:className idx:0];
}

-(BOOL) clickNodeWithClass:(NSString *)className idx:(NSUInteger) idx
{
	[self registFunc:s_clickInternalAtf];
	[self registFunc:s_clickNodeWithClass];

	NSString* call = [NSString stringWithFormat:@"clickNodeWithClassAtf('%@', %u);", className, idx];
	NSString* res = [self callFunc:call];

	RETURN_AS_BOOL(res);
}


-(BOOL) clickNodeWithTag:(NSString*) tagName
{
	[self clickNodeWithTag:tagName idx:0];
}

-(BOOL) clickNodeWithTag:(NSString*) tagName idx:(NSUInteger) idx
{
	[self registFunc:s_clickInternalAtf];
	[self registFunc:s_clickNodeWithTag];

	NSString* call = [NSString stringWithFormat:@"clickNodeWithTagAtf('%@', %u);", tagName, idx];
	NSString* res = [self callFunc:call];

	RETURN_AS_BOOL(res);
}

-(BOOL) clickNodeWithID:(NSString*) nodeID
{
	[self registFunc:s_clickInternalAtf];
	[self registFunc:s_clickNodeWithID];

	NSString* call = [NSString stringWithFormat:@"clickNodeWithIDAtf('%@');", nodeID];
	NSString* res = [self callFunc:call];

	RETURN_AS_BOOL(res);
}

-(NSUInteger) getNodeWithClassNum:(NSString*) className
{
	[self registFunc:s_getNodeWithClassNum];

	NSString* call = [NSString stringWithFormat:@"getNodeWithClassNumAtf('%@');", className];

	NSString* res = [self callFunc:call];
	RETURN_AS_INT(res);
}

-(NSString*) getNodeWithClassDesc:(NSString*) className idx:(NSUInteger) idx
{
	[self registFunc:s_getNodeDesc];
	[self registFunc:s_getNodeWithClassDesc];

	NSString* call = [NSString stringWithFormat:@"getNodeWithClassDescAtf('%@', %d);", className, idx];
	NSString* result = [self callFunc:call];
	return result;
}

-(BOOL) clickNodeWithValue:(NSString*) value
{
	[self clickNodeWithValue:value idx:0];
}

-(BOOL) clickNodeWithValue:(NSString*) value idx:(NSUInteger) idx
{
	[self registFunc:s_getNodeWithValueInAry];
	[self registFunc:s_getNodeTypeDesc];
	[self registFunc:s_clickNodeWithValue];
	[self registFunc:s_clickInternalAtf];

	NSString* call = [NSString stringWithFormat:@"clickNodeWithValueAtf('%@', %u)", value, idx];

	NSString* res = [self callFunc:call];

	RETURN_AS_BOOL(res);
}

-(NSUInteger) getNodeWithValueNum:(NSString*) value
{
	[self registFunc:s_getNodeWithValueInAry];
	[self registFunc:s_getNodeWithValueNum];

	NSString* call = [NSString stringWithFormat:@"getNodeWithValueNumAtf('%@');", value];

	NSString* res  = [self callFunc:call];


	RETURN_AS_INT(res);
}

-(NSString*) getNodeWithValueDesc:(NSString*) value idx:(NSUInteger) idx
{
	[self registFunc:s_getNodeDesc];
	[self registFunc:s_getNodeWithValueDesc];
	[self registFunc:s_getNodeWithValueInAry];

	NSString* call = [NSString stringWithFormat:@"getNodeWithValueDescAtf('%@', %u);", value, idx];
	NSString* res = [self callFunc:call];

	return res;
}

-(NSString*) getNodeWithTagDesc:(NSString*) tagName idx:(NSUInteger) idx
{
	[self registFunc:s_getNodeWithTagDesc];
	[self registFunc:s_getNodeDesc];

	NSString* call = [NSString stringWithFormat:@"getNodeWithTagDescAtf('%@', %u);", tagName, idx];
	NSString* res = [self callFunc:call];

	return res;
}

-(NSUInteger) getNodeWithTagNum:(NSString*) tagName
{
	[self registFunc:s_getNodeWithTagNum];

	NSString* call = [NSString stringWithFormat:@"getNodeWithTagNumAtf('%@');", tagName];
	NSString* res = [self callFunc:call];

	RETURN_AS_INT(res);
}

-(BOOL) setInputValue:(NSString*) value idx:(NSUInteger) idx
{
	[self registFunc:s_setInputValue];

	NSString* call = [NSString stringWithFormat:@"setInputValueAtf('%@', %u);", value, idx];
	NSString* res = [self callFunc:call];

	RETURN_AS_BOOL(res);
}

-(BOOL) setInputChecked:(BOOL) checked idx:(NSUInteger) idx
{
	NSString* value = checked ? @"true" : @"false";

	NSString* res = [self setInputAttr:@"checked" val:value idx:idx];

	if([res isEqualToString:value])
		return YES;
	return NO;
}

-(NSString*) getInputAttr:(NSString*) attrName idx:(NSUInteger) idx
{
	[self registFunc:s_getNodeAttr];

	NSString* call = [NSString stringWithFormat:@"getNodeAttrAtf('INPUT', %u, '%@');", idx, attrName];
	NSString* res = [self callFunc:call];

	return res;
}

-(NSString*) setInputAttr:(NSString*) attrName val:(NSString*) attrValue idx:(NSUInteger) idx
{
	[self registFunc:s_setNodeAttr];
	NSString* call = [NSString stringWithFormat:@"setNodeAttrAtf('INPUT', %u, '%@', '%@');", idx, attrName, attrValue];
	NSString* res = [self callFunc:call];
	return res;
}

-(void) goBackAtf
{
	[self goBack];
}

-(void) goForwardAtf
{
	[self goForward];
}


-(void) printAllNodesDescWithClass:(NSString*) className
{
    NSUInteger total = [self getNodeWithClassNum:className];
    for(int i = 0; i < total; i++){
        NSString* desc = [self getNodeWithClassDesc:className idx:i];
        ATLogMessageFormat(@"%d\t%@", i, desc);
    }
}

-(void) printAllNodesDescWithValue:(NSString*) value
{
    NSUInteger total = [self getNodeWithValueNum:value];
    for(int i = 0; i < total; i++){
        NSString* desc = [self getNodeWithValueDesc:value idx:i];
        ATLogMessageFormat(@"%d\t%@", i, desc);
    }
}

-(void) printAllNodesDescWithTag:(NSString*) tagName
{
    NSUInteger total = [self getNodeWithTagNum:tagName];
    for(int i = 0; i < total; i++){
        NSString* desc = [self getNodeWithTagDesc:tagName idx:i];
        ATLogMessageFormat(@"%d\t%@", i, desc);
    }
}

@end
