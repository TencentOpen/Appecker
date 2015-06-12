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

#import "ATCAAnimationHook.h"
#import "AppeckerHookManager.h"
#import "ATAnimationDelegateWrapper.h"

@implementation CAAnimation (ATCAAnimationHook)


+(void) load
{
    if(self != [CAAnimation class])
        return;

    [AppeckerHookManager hijackInstanceSelector:@selector(setDelegate:) inClass:[self class] withSelector:@selector(atfSetDelegate:) inClass:[self class]];
}


-(void) atfSetDelegate:(id) delegate
{
    if(!delegate){
        NSLog(@"delegate is set to nil!");
        return;
    }

    ATAnimationDelegateWrapper* wrapper = [[ATAnimationDelegateWrapper alloc] initWithDelegate:delegate];
    [self atfSetDelegate:wrapper];
    [wrapper release];
}

@end
