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

#import "ATUICommon.h"

@implementation UIView (ATUICcommon)

-(void) atfActionBubbleUp:(SEL) action
{
    for(UIResponder* next = [self nextResponder]; next != nil; next = [next nextResponder]){
        if(![next respondsToSelector:action])
            continue;
        [self sendAction:action to:next forEvent:nil];
    }
}


-(void) atfActivateEvent:(UIControlEvents) event
{
    if(![self isKindOfClass:[UIControl class]])
        return;

    NSSet *targets = [self allTargets];
    for(id target in targets)
    {
        if([target isKindOfClass:[NSNull class]])
            target = nil;

        NSArray *actions = [self actionsForTarget:target forControlEvent:event];

        for(int i=0; i<[actions count]; i++)
        {
			SEL action = NSSelectorFromString([actions objectAtIndex:i]);
            if(target == nil)
                [self atfActionBubbleUp:action];
            else
                [self sendAction:action to:target forEvent:nil];
        }
    }
}
@end
