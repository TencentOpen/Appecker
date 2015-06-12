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

#import "Appecker.h"
#import "AppeckerPrivate.h"
#import "ATWaitUtilityPrivate.h"

static Appecker* s_instance = nil;

@interface Appecker(Private)
-(void) AppeckerStart;
-(void) AppeckerLeave;
-(void) initialize;
@end

@implementation Appecker

+(Appecker*) sharedInstance
{
    if(s_instance==nil){
        s_instance = [[Appecker alloc] init];
    }

    return s_instance;
}

-(BOOL) isInMacroRecMode
{
    return m_macroRecMode;
}

-(BOOL) isBackground
{
    return m_background;
}


-(id) init
{
    if(s_instance)
        [NSException raise:@"Singleton" format:@"You are initializing a singleton!"];

    if(self = [super init]){
        m_start = YES;
        m_macroRecMode = NO;
        m_background = NO;
    }

    return self;
}

-(void) didEnterBackground
{
    m_background = YES;
    ATLogMessage(@"App did enter background!");
}

-(void) willEnterForeground
{
    m_background = NO;
    ATLogMessage(@"App will enter foreground!");
}

-(void) onBeginTouch:(UIView*) view
{
    if (self.isBackground)
        AppeckerBlock();
}

-(void) turnOff
{
    m_start = NO;
}

-(void) enableMacroRecMode;
{
    m_macroRecMode = YES;
}

-(void) onAppFinishedLaunching
{
    ATSay(@"Application Finished launching!");

    if(!m_start){
        ATSay(@"Appecker is tuned to be off-line!");
        return;
    }

    ATSay(@"Now launching Appecker....");

    [self performSelector:@selector(AppeckerStart) withObject:nil afterDelay:0.01];

}

-(void) AppeckerStart
{
    if (m_macroRecMode) {
        ATSay(@"Entering macro record mode...");
        return;
    }

    NSProcessInfo* processInfo = [NSProcessInfo processInfo];
    NSArray* args = [processInfo arguments];
    int argc = [args count];
    const char** argv = (const char**)malloc(sizeof(char*) * argc);
    for(int i = 0; i < argc; i ++){
        argv[i] = (char*)[[args objectAtIndex:i] UTF8String];
    }

    [ATLauncher setupWithArgs:argv count:argc];

    free(argv);

    [ATLauncher run];
}

-(void) AppeckerLeave
{
    if(m_macroRecMode){
        ATSay(@"Leaving macro record mode...");
        return;
    }

    [ATLauncher tearDown];
}

-(void) onAppWillTerminate
{
    ATSay(@"Application will terminate!");

    if(!m_start){
        ATSay(@"Appecker is tuned to be off-line!");
        return;
    }

    ATSay(@"Now tearing down Appecker....");
    [self AppeckerLeave];
}

-(void) initialize
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppFinishedLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillTerminate) name:UIApplicationWillTerminateNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    ATSay(@"Appecker initialized!");
}

@end
