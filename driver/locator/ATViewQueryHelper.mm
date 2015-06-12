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

#import "ATViewQuery.h";

@implementation ATViewQuery (ATViewQueryHelper)

+(UIView *)findViewInTree:(UIView *)rootView byAttributeName:(NSString *)attrName attributeValue:(NSString *)attrValue
{
    UIView *resultView = nil;
    ATCondition * andCon = [ATCondition conditionWithArrributeName:attrName attributeValue:attrValue];
    resultView = [ATViewQuery findFirstViewInTree:rootView byCondition:andCon];
    return [[resultView retain] autorelease];
}

//provide a attributes list, get the view
+(UIView *)findViewInTree:(UIView *)rootView byAttributes:(NSDictionary *)attributesSet
{
    UIView *resultView = nil;
    ATCondition * andCon = [ATCondition conditionWIthAttributes:attributesSet];
    resultView = [ATViewQuery findFirstViewInTree:rootView byCondition:andCon];
    return [[resultView retain] autorelease];
}


+(UIView *)findViewInTree:(UIView *)rootView byTag:(int)tag
{
    if(rootView == nil)
    {
        rootView = [[UIApplication sharedApplication] keyWindow];
    }
    return [rootView viewWithTag:tag];
}

+(UIView *)findViewInMainWindowByTag:(int)tag
{
    return [[[UIApplication sharedApplication] keyWindow] viewWithTag:tag];
}

+(UIView *)findViewInWindowsByTag:(int)tag
{
    UIView *resultView = nil;
    NSArray *wArray = [[UIApplication sharedApplication] windows];

    for(int i=0; i< [wArray count]; i++)
    {
        UIWindow *wd = [wArray objectAtIndex:i];
        UIView *view = [wd viewWithTag:tag];
        if(view != nil)
        {
            resultView = view;
            break;
        }
    }
    return resultView;
}

@end
