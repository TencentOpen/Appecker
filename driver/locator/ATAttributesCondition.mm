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

#import "ATAttributesCondition.h"


@implementation ATAttributesCondition

-(id)initWithArrributeName:(NSString *)attrName attributeValue:(NSString *)attrValue
{
    self = [super init];
    if(self != nil)
    {
        attributeDict = [[NSDictionary alloc] initWithObjectsAndKeys:attrValue, attrName, nil];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)attributes{
    self = [super init];
    if(self != nil){
        attributeDict = [[NSDictionary alloc] initWithDictionary:attributes];
    }
    return self;
}


-(BOOL)check:(UIView *)view
{
    for(NSString *key in attributeDict){
        SEL attrSel = sel_registerName([key UTF8String]);
        NSString *value = [attributeDict valueForKey:key];

        if([view respondsToSelector:attrSel])
        {
            id attrValue = [view performSelector:attrSel];
            if(![attrValue isKindOfClass:[NSString class]])
                return NO;

            if(![attrValue isEqualToString:value])
                return NO;
        }
        else {
            return NO;
        }

    }
    return YES;
}

-(void)dealloc
{
    [attributeDict release];
    [super dealloc];
}

@end
