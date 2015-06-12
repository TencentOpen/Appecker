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


@interface UIWebView ( ATWebView )

-(void) printInnerHTML;
-(NSString*) getInnerHTML;
-(NSString*) callFunc:(NSString*) call;
-(void) registFunc:(NSString*) funcText;
-(NSString*) getDOMTree;
-(void) printDOMTree;
-(BOOL) clickNodeWithClass:(NSString*) className;
-(BOOL) clickNodeWithClass:(NSString *)className idx:(NSUInteger) idx;
-(BOOL) clickNodeWithID:(NSString*) nodeID;
-(BOOL) clickNodeWithValue:(NSString*) value;
-(BOOL) clickNodeWithValue:(NSString*) value idx:(NSUInteger) idx;
-(BOOL) clickNodeWithTag:(NSString*) tagName;
-(BOOL) clickNodeWithTag:(NSString*) tagName idx:(NSUInteger) idx;
-(BOOL) isFuncExist:(NSString*) funcName;
-(BOOL) setInputValue:(NSString*) value idx:(NSUInteger) idx;
-(BOOL) setInputChecked:(BOOL) checked idx:(NSUInteger) idx;
-(NSUInteger) getNodeWithClassNum:(NSString*) className;
-(NSString*) getNodeWithClassDesc:(NSString*) className idx:(NSUInteger) idx;
-(void) printAllNodesDescWithClass:(NSString*) className;
-(NSUInteger) getNodeWithValueNum:(NSString*) value;
-(NSString*) getNodeWithValueDesc:(NSString*) value idx:(NSUInteger) idx;
-(void) printAllNodesDescWithValue:(NSString*) value;
-(NSUInteger) getNodeWithTagNum:(NSString*) tagName;
-(NSString*) getNodeWithTagDesc:(NSString*) tagName idx:(NSUInteger) idx;
-(void) printAllNodesDescWithTag:(NSString*) tagName;
-(NSString*) getInputAttr:(NSString*) attrName idx:(NSUInteger) idx;
-(NSString*) setInputAttr:(NSString*) attrName val:(NSString*) attrValue idx:(NSUInteger) idx;
-(void) goBackAtf;
-(void) goForwardAtf;
@end
