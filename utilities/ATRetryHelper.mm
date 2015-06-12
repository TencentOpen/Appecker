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

#import "ATRetryHelper.h"
#import "ATException.h"


@implementation ATRetryHelper

+(BOOL) tryTaskWithSelector:(SEL) taskSelector target:aTarget quitAfter:(NSTimeInterval) interval
{
    return [self tryTaskWithSelector:taskSelector target:aTarget quitAfter:interval expecting:YES];
}

+(BOOL) tryTaskWithSelector:(SEL) taskSelector
                     target:aTarget
                  quitAfter:(NSTimeInterval) interval
                  expecting:(BOOL) expectedResult
{
    NSMethodSignature *signature = [aTarget methodSignatureForSelector:taskSelector];
    int parameterNumber = [signature numberOfArguments];
    if(parameterNumber > 3){
        ATException * ex = [ATException exceptionWithMessage:@"Invalid selector"];
        @throw ex;
    }

    const NSTimeInterval checkInterval = 0.5;
    BOOL succeeded = NO;
    NSDate * quitTime = [NSDate dateWithTimeIntervalSinceNow:interval];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:aTarget];
    [invocation setSelector:taskSelector];
    while(true){
        BOOL lastChance = [quitTime timeIntervalSinceNow] <= 0.0;
        if(parameterNumber == 3){
            [invocation setArgument:&lastChance atIndex:2];
        }
        [invocation invoke];
        BOOL result = NO;
        [invocation getReturnValue:&result];
        succeeded = (result == expectedResult);
        if(succeeded || lastChance){
            break;
        }
        [NSThread sleepForTimeInterval:checkInterval];
    };

    return succeeded;
}

@end
