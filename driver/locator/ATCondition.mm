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

#import "ATCondition.h"
#import "ATClassCondition.h"
#import "ATAttributesCondition.h"
#import "ATFrameCondition.h"
#import "ATSubViewDescCondition.h"
#import "ATKeywordCondition.h"

@implementation ATCondition

-(BOOL)check:(UIView *)view
{
    return FALSE;
}

@end


@implementation ATCondition (ATConditionFacotry)

+(ATCondition *) conditionWithArrributeName:(NSString *)attrName attributeValue:(NSString *)attrValue{
    return [[[ATAttributesCondition alloc] initWithArrributeName:attrName attributeValue:attrValue] autorelease];
}

+(ATCondition *) conditionWIthAttributes:(NSDictionary *)attributes{
    return [[[ATAttributesCondition alloc] initWithDictionary:attributes] autorelease];
}

+(ATCondition *) conditionWithClassName:(NSString *)className{
    return [[[ATClassCondition alloc] initWithClassName:className] autorelease];
}

+(ATCondition *) conditionWithClass:(Class)classObj{
    return [[[ATClassCondition alloc] initWithClass:classObj] autorelease];
}

+(ATCondition *) conditionWithFrame:(CGRect) frame bias:(NSUInteger) bias
{
	return [[[ATFrameCondition alloc] initWithFrameRect:frame bias:bias] autorelease];
}

+(ATCondition *) conditionWithAttributeName:(NSString*) attributeName attrValKeyword:(NSString*) keyword
{
	return [[[ATKeywordCondition alloc] initWithAttributeName:attributeName attrValKeyword:keyword] autorelease];
}

+(ATCondition *) conditionWithSubViewDesc:(NSString*) desc
{
	return [[[ATSubViewDescCondition alloc] initWithStringDesc:desc] autorelease];
}
@end