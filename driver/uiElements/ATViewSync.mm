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

#import "ATView.h"
#import "ATWindow.h"
#import "ATWaitUtility.h"

#define ATViewSyncWait() {                      \
    AppeckerWait(timeSlice);  \
    totalWaitTime += timeSlice;                 \
    }

@implementation UIView (ATViewSync)

+(BOOL) waitViewToAppear:(NSString*) viewClassName num:(NSUInteger) minNum timeout:(NSTimeInterval) timeout
{
    if(minNum == 0)
        return NO;

    if(timeout < 0.0f)
        return NO;

    BOOL res = NO;
    NSTimeInterval totalWaitTime = 0.0f;
    const NSTimeInterval timeSlice = 0.2f;
    int visibleCnt = 0;

    while (YES) {
        ATViewSyncWait();
        NSArray* ary = [[UIWindow mainWindow] LocateViewsByExactClassName:viewClassName];

        if (res)
            break;

        if(timeout != 0.0f && totalWaitTime >= timeout)
            break;

        if([ary count] < minNum){
            continue;
        }

        for(UIView* view in ary){
            if([view atfVisible])
                visibleCnt ++;

            if(visibleCnt >= minNum){
                res = YES;
                break;
            }

        }
    }

    return res;
}

+(BOOL) waitOnSingleView:(NSString*) viewClassName forTime:(NSTimeInterval) timeout
{
    [self waitViewToAppear:viewClassName num:1 timeout:timeout];
}

+(BOOL) waitOnSingleView:(NSString*) viewClassName
{
    [self waitOnSingleView:viewClassName forTime:0.0f];
}

@end
