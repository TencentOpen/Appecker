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

#import "ATViewQuery.h"
#import "ATCondition.h"


@implementation ATViewQuery

+(UIView *)findFirstViewInSubViews:(UIView *)parentView byCondition:(ATCondition *)condition
{
    UIView *resultView = nil;

    for(UIView* tempView in [parentView subviews])
    {
        if([condition check:tempView])
        {
            resultView = tempView;
            break;
        }
    }

    if(resultView == nil)
    {
        for(UIView* tempView in [parentView subviews])
        {
            resultView = [self findFirstViewInTree:tempView byCondition:condition];
            if(resultView != nil)
            {
                break;
            }
        }
    }
    return resultView;
}

+(UIView *)findFirstViewInTree:(UIView *)rootView byCondition:(ATCondition *)condition
{
    if([condition check:rootView])
    {
        return rootView;
    }
    return [self findFirstViewInSubViews:rootView byCondition:condition];
}


+(NSArray *)findAllViewsInSubViews:(UIView *)parentView byCondition:(ATCondition *)condition
{
    NSMutableArray *resultViewsArray = [[[NSMutableArray alloc] init] autorelease];
    NSArray *subViews = [parentView subviews];
    for(UIView* tempView in subViews)
    {
        if([condition check:tempView])
        {
            [resultViewsArray addObject:tempView];
        }
    }


    for(int i=0; i<[subViews count]; i++)
    {
        UIView* tempView = [subViews objectAtIndex:i];
        if(tempView != nil)
        {
            NSArray *resultSubViews = [self findAllViewsInSubViews:tempView byCondition:condition];
            [resultViewsArray addObjectsFromArray:resultSubViews];
        }

    }
    return resultViewsArray;
}


+(NSArray *)findAllViewsInTree:(UIView *)rootView byCondition:(ATCondition *)condition
{
    NSMutableArray *resultViewsArray = [[[NSMutableArray alloc] init] autorelease];
    if(rootView == nil)
    {

        rootView = [[UIApplication sharedApplication] keyWindow];
    }

    if([condition check:rootView])
    {
        [resultViewsArray addObject:rootView];
    }

    NSArray *resultSubViews = [self findAllViewsInSubViews:rootView byCondition:condition];
    [resultViewsArray addObjectsFromArray:resultSubViews];

    return resultViewsArray ;
}


@end


