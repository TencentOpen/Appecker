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

#import "ATAndConditions.h"

@implementation ATAndConditions
@synthesize andConditions = _andConditions;

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        _andConditions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithConditions:(ATCondition *) firstCondition, ...
{
    self = [super init];
    if(self != nil){
        _andConditions = [[NSMutableArray alloc] init];
        if (firstCondition)                         // The first argument isn't part of the varargs list,
        {                                           // so we'll handle it separately.
            [_andConditions addObject: firstCondition];
            va_list argumentList;
            ATCondition * eachCondition;
            va_start(argumentList, firstCondition);                         // Start scanning for arguments after firstObject.
            while (nil != (eachCondition = va_arg(argumentList, ATCondition*)))    // As many times as we can get an argument of type (ATCondition *)
                [_andConditions addObject: eachCondition];               // that isn't nil, add it to self's contents.
            va_end(argumentList);
        }
    }
    return self;
}

-(void)addCondition:(ATCondition *)condition
{
    [_andConditions addObject:condition];
}

-(void)addConditions:(NSArray *)conditions
{
    [_andConditions addObjectsFromArray:conditions];
}

-(BOOL)check:(UIView *)view
{
    for(int i=0; i< [self.andConditions count]; i++)
    {

        ATCondition *filter = [self.andConditions objectAtIndex:i];
        if(![filter check:view])
        {
            return FALSE;
        }
    }
    return TRUE;
}

-(void)dealloc
{
    [_andConditions release], _andConditions = nil;
    [super dealloc];
}
@end
