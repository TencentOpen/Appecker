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

#import "ATSubViewDescCondition.h"
#import "ATViewQuery.h"



@implementation ATSubViewDescCondition

-(id) initWithStringDesc:(NSString *)desc
{
	if (self = [super init]) {
		subviewInfo = [[NSMutableDictionary alloc] initWithCapacity:3];

		NSRange range;

		int subviewDescStart, subviewDescEnd;

		range = [desc rangeOfString:@"{"];
		subviewDescStart = range.location;

		range = [desc rangeOfString:@"}"];
		subviewDescEnd = range.location;

		NSCharacterSet* trimSet = [NSCharacterSet whitespaceCharacterSet];

		rootViewClassName = [[NSString alloc] initWithString:[[desc substringToIndex:subviewDescStart] stringByTrimmingCharactersInSet:trimSet]];

		range.location = subviewDescStart + 1;
		range.length = subviewDescEnd - subviewDescStart - 1;
		NSString* subViewDesc = [desc substringWithRange:range];

		NSArray* subViewDescSplit = [subViewDesc componentsSeparatedByString:@","];


		NSNumber* subViewCnt;
		NSString* subClassName;
		for( NSString *entry in subViewDescSplit)
		{
			entry = [entry stringByTrimmingCharactersInSet:trimSet];
			NSArray* entrySplit = [entry componentsSeparatedByString:@":"];
			subClassName = [entrySplit objectAtIndex:0];
			subViewCnt =  [NSNumber numberWithInt:[[entrySplit objectAtIndex:1] intValue]];

			[subviewInfo setObject:subViewCnt forKey:subClassName];
		}

	}
	return self;
}

-(BOOL) check:(UIView *)view
{
	NSString* className;

	className = NSStringFromClass([view class]);

	if (![className isEqualToString:rootViewClassName])
		return NO;

	ATCondition *subViewCondition;
	NSArray* subViews;
	int viewCnt;
	for(NSString* subViewClassName in subviewInfo){
		subViewCondition = [ATCondition conditionWithClassName:subViewClassName];
		viewCnt = [[subviewInfo objectForKey:subViewClassName] intValue];
		subViews = [ATViewQuery findAllViewsInSubViews:view byCondition:subViewCondition];
		if([subViews count] < viewCnt) {
			return NO;
		}
	}

	return YES;
}

-(void) dealloc
{
	[subviewInfo release];
	[super dealloc];
}

@end