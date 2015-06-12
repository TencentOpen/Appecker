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

#import "ATWaitUtility.h"
#import "AppeckerPrivate.h"
#import "ATAnimationManager.h"

static BOOL s_canWait = YES;

void AppeckerLockWait()
{
    s_canWait = NO;
}

void AppeckerUnlockWait()
{
    s_canWait = YES;
}

void AppeckerRunLoop()
{
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    [runLoop runMode:UITrackingRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    [runLoop runMode:NSDefaultRunLoopMode  beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

void AppeckerWait(NSTimeInterval time)
{
    if(!s_canWait)
        return;

    ATAnimationManager* mgr = [ATAnimationManager sharedInstance];

    NSTimeInterval lastTick = [[NSDate date] timeIntervalSince1970];
    while (YES) {
        AppeckerRunLoop();
        NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSince1970] - lastTick;
        if(timeElapsed >= time){
            while (![mgr isAllAnimationFinished]) {
                AppeckerRunLoop();
            }

            break;
        }

    }
}

void AppeckerBlock()
{
    Appecker* AppeckerRef = [Appecker sharedInstance];
    while (YES) {
        AppeckerWait(0.1);
        if(!AppeckerRef.isBackground)
            break;
    }
}