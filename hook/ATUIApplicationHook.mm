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

#import "ATUIApplicationHook.h"
#import "Appecker.h"
#import "ATMacroRec.h"
#import "ATMacroRecSwitch.h"
#import "AppeckerPrivate.h"
#import "ATWaitUtilityPrivate.h"
#import <QuartzCore/QuartzCore.h>
#import "AppeckerHookManager.h"

static BOOL s_initialized = NO;

@implementation UIApplication (ATUIApplicationHook)

+(void) load
{
    if(self != [UIApplication class])
        return;

    ATSay(@"Loading Appecker...");

    [[Appecker sharedInstance] initialize];
    [AppeckerHookManager hijackInstanceSelector:@selector(sendEvent:) inClass:[self class] withSelector:@selector(atfSendEvent:) inClass:[self class]];
}




-(void) atfSendEvent:(UIEvent *)event
{
    Appecker* AppeckerRef = [Appecker sharedInstance];

    if ([[Appecker sharedInstance] isInMacroRecMode]) {
        if(!s_initialized){
            s_initialized = YES;
            ATMacroRecSwitch* switcher = [ATMacroRecSwitch sharedInstance];
            [switcher show];
            [switcher setDoubleTapAction:@selector(startCaseRec) target:[ATMacroRec sharedInstance]];
        }

        NSString* eventName = NSStringFromClass([event class]);

        if ([eventName isEqualToString:@"UITouchesEvent"]) {
            [[ATMacroRec sharedInstance] onTouchEvent:event];
        }
    }

    [self atfSendEvent:event];


}

@end
