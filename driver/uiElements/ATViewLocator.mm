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

#import "ATView.h"
#import "Locator.h"
#import "ATUtilities.h"


@implementation UIView (ATViewLocator)

-(id) LocateViewByCondition: (ATCondition *)condition{
    id result = [ATViewQuery findFirstViewInTree:self byCondition:condition];
    return result;
}

-(NSArray *) LocateViewsByCondition: (ATCondition *)condition{
    return [ATViewQuery findAllViewsInTree:self byCondition:condition];
}

-(id) LocateViewByClassName: (NSString *) className
{
    ATCondition *condition = [ATCondition conditionWithClassName:className];
    return [self LocateViewByCondition:condition];
}

-(id) LocateViewsByClassName: (NSString *) className
{
    ATCondition *condition = [ATCondition conditionWithClassName:className];
    return [self LocateViewsByCondition:condition];
}

-(id) LocateViewByClass: (Class) type
{
    ATCondition *condition = [ATCondition conditionWithClass:type];
    return [self LocateViewByCondition:condition];
}

-(id) LocateViewsByClass: (Class) type
{
    ATCondition *condition = [ATCondition conditionWithClass:type];
    return [self LocateViewsByCondition:condition];
}

-(id) LocateViewByExactClassName: (NSString *) className
{
    ATExactClassCondition *condition = [[[ATExactClassCondition alloc] initWithClassName:className] autorelease];
    return [self LocateViewByCondition:condition];
}

-(id) LocateViewsByExactClassName: (NSString *) className
{
    ATExactClassCondition *condition = [[[ATExactClassCondition alloc] initWithClassName:className] autorelease];
    return [self LocateViewsByCondition:condition];
}

-(id) LocateViewByExactClass: (Class) type
{
    ATExactClassCondition *condition = [[[ATExactClassCondition alloc] initWithClass:type] autorelease];
    return [self LocateViewByCondition:condition];
}


-(id) LocateViewsByExactClass: (Class) type
{
    ATExactClassCondition *condition = [[[ATExactClassCondition alloc] initWithClass:type] autorelease];
    return [self LocateViewsByCondition:condition];
}

-(id) LocateViewByTag:(NSInteger)tag
{
    id result = [ATViewQuery findViewInTree:self byTag:tag];
    return result;
}

-(id) LocateViewByAttributes:(NSDictionary *)attributesSet
{
    ATCondition * condition = [ATCondition conditionWIthAttributes:attributesSet];
    return [self LocateViewByCondition:condition];
}

-(id) LocateViewByAttributeName:(NSString *)attributeName attributeValue:(NSString *)attributeValue
{
    ATCondition * condition = [ATCondition conditionWithArrributeName:attributeName attributeValue:attributeValue];
    return [self LocateViewByCondition:condition];
}

-(id) LocateViewByCondition: (ATCondition *)condition occurAt:(int)times
{
    if(index <= 0){
        return nil;
    }
    NSArray *views = [self LocateViewsByCondition:condition];
    UIView *view = nil;
    if([views count] >= times)
    {
        view = [views objectAtIndex:(times - 1)];
    }
    return view;
}

-(id) LocateViewByClassName: (NSString *) className occurAt:(int)times
{
    ATCondition *condition = [ATCondition conditionWithClassName:className];
    return [self LocateViewByCondition:condition occurAt:times];
}

-(id) LocateViewByClass: (Class) type occurAt:(int)times
{
    ATCondition *condition = [ATCondition conditionWithClass:type];
    return [self LocateViewByCondition:condition occurAt:times];
}

-(id) LocateViewByAttributes:(NSDictionary *)attributesSet occurAt:(int)times
{
    ATCondition * condition = [ATCondition conditionWIthAttributes:attributesSet];
    return [self LocateViewByCondition:condition occurAt:times];

}
-(id) LocateViewByAttributeName:(NSString *)attributeName attributeValue:(NSString *)attributeValue occurAt:(int)times
{
    ATCondition * condition = [ATCondition conditionWithArrributeName:attributeName attributeValue:attributeValue];
    return [self LocateViewByCondition:condition occurAt:times];
}


-(id) LocateViewByExactFrame:(CGRect) frame
{
	ATCondition *condition = [ATCondition conditionWithFrame:frame bias:0];
	return [self LocateViewByCondition:condition];
}

-(id) LocateViewByFrame:(CGRect) frame bias:(NSUInteger) bias
{
	ATCondition *condition = [ATCondition conditionWithFrame:frame bias:bias];
	return [self LocateViewByCondition:condition];
}

-(id) LocateViewBySiblingAttr:(NSString*) attrName attrValKeyword:(NSString*)keyword index:(NSUInteger) idx
{
	ATCondition *condition = [ATCondition conditionWithAttributeName:attrName attrValKeyword:keyword];
	UIView* view = [self LocateViewByCondition:condition];

    if(view == nil)
        return nil;

    UIView* superView = view.superview;

    NSUInteger srcIdx = [superView.subviews indexOfObject:view];

    if(srcIdx == NSNotFound)
        return nil;

    NSUInteger dstIdx = srcIdx + idx;

    UIView* res;

    @try {
        res = [superView.subviews objectAtIndex:dstIdx];
    }
    @catch (NSException *exception) {
        res = nil;
    }

    return res;
}

-(id) LocateParentViewByChildAttr:(NSString*) attrName attrValkeyword:(NSString*) keyword
{
    ATCondition *condition = [ATCondition conditionWithAttributeName:attrName attrValKeyword:keyword];
	UIView* view = [self LocateViewByCondition:condition];

    if(view == nil)
        return nil;

    return view.superview;
}

-(id) LocateViewByAttributeName:(NSString*) attrName attrValKeyword:(NSString *)keyword
{
	ATCondition *condition = [ATCondition conditionWithAttributeName:attrName attrValKeyword:keyword];
	return [self LocateViewByCondition:condition];
}

-(id) LocateViewsBySubViewDesc:(NSString*) subViewDesc
{
	ATCondition *condition = [ATCondition conditionWithSubViewDesc:subViewDesc];
	return [self LocateViewsByCondition:condition];
}

@end
