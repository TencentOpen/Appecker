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

#import "ATOrConditions.h"


@implementation ATOrConditions
@synthesize orConditions = _orConditions;


- (id) initWithConditions:(ATCondition *) firstCondition, ...
{
    self = [super init];
    if(self != nil){
        _orConditions = [[NSMutableArray alloc] init];
        if (firstCondition)                         // The first argument isn't part of the varargs list,
        {                                           // so we'll handle it separately.
            [_orConditions addObject: firstCondition];
            va_list argumentList;
            ATCondition * eachCondition;
            va_start(argumentList, firstCondition);
            // Start scanning for arguments after firstObject.
            // As many times as we can get an argument of type (ATConditio *)
            while ((eachCondition = va_arg(argumentList, ATCondition *)) != nil){
                [_orConditions addObject: eachCondition];

            }
            va_end(argumentList);
        }
    }
    return self;
}


-(id)init
{
    self = [super init];
    if(self != nil)
    {
        _orConditions = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addCondition:(ATCondition *)condition
{
    [_orConditions addObject:condition];
}

-(void)addConditions:(NSArray *)conditions
{
    [_orConditions addObjectsFromArray:conditions];
}

-(BOOL)check:(UIView *)view
{
    for(ATCondition *condition in self.orConditions)
    {
        if([condition check:view])
        {
            return TRUE;
        }
    }
    return FALSE;
}

-(void)dealloc
{
    [_orConditions release];
    [super dealloc];
}

@end

