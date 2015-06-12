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

#import "ATKeywordCondition.h"

@implementation ATKeywordCondition

-(id) initWithAttributeName:(NSString *)attrName_a attrValKeyword:(NSString *)keyword_a
{
	if (self = [super init]) {
		attrName = [[NSString alloc] initWithString:attrName_a];
		keyword = [[NSString alloc] initWithString:keyword_a];
	}
	return self;
}

-(void) dealloc
{
	[attrName release];
	[keyword release];
	[super dealloc];
}



-(BOOL) check:(UIView *)view
{
    SEL attrSel = sel_registerName([attrName UTF8String]);

	if(![view respondsToSelector:attrSel]) return NO;

	id attrVal = [view performSelector:attrSel];

	if (![attrVal isKindOfClass:[NSString class]]) return NO;

	NSString *textAttrVal = attrVal;

	NSRange range = [textAttrVal rangeOfString:keyword];
	if(range.location == NSNotFound) return NO;

    return YES;
}

@end

