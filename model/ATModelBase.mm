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

#import "ATModel.h"
#import "ATModelEngine.h"
#import "ATAction.h"
#import "ATLogger.h"

@implementation ATModelBase

@synthesize factor;

-(id) init{
    self = [super init];
    if(nil != self){
        factor = 1.0;
    }
    return self;
}

-(void)dealloc{
    [actions release];
    [super dealloc];
}

-(NSArray *) actions{

    if(nil == actions ){
        NSArray *registeredActions = [self registerActions];
        actions = [[NSMutableArray alloc] initWithArray: registeredActions];
        for(ATAction *action in actions)
        {
            if(![self respondsToSelector:action.selector])
            {
                ATLogWarning([NSString stringWithFormat:@"Registered action %@ not found in model %@",
                              NSStringFromSelector(action.selector),
                              NSStringFromClass([self class])]);
                action.enabled = NO;
            }
        }
    }
    return actions;
}

-(ATModelEngine *) engine{
    NSAssert(YES, @"This method MUST be overloaded in subclasses.");
    return nil;
}


-(NSArray *) registerActions
{
    return [NSArray arrayWithObjects:
            nil];
}

@end
