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

#import "ATExceptionHandler.h"
#import "ATLogger.h"
#import "ATCaseRunner.h"
#import "ATExceptionHandlerPrivate.h"
#import "ATCaseRunnerPrivate.h"


void sighandler(int signal)
{
	ATLogErrorFormat(@"signal received:%d",signal);
	[[ATExceptionHandler sharedInstance] messCleaner];

    if(signal == 2 || signal == 15)//SIGINT and SIGTERM will cause a graceful exit.
        [[UIApplication sharedApplication] performSelectorOnMainThread:@selector(terminateWithSuccess) withObject:nil waitUntilDone:TRUE];

    //Other signals would cause a crash log to be generated
}


void handleException(NSException *exception)
{
	ATLogMessageFormat(@"exception received:%@", [exception name]);
	ATLogMessage(@"Uncaught exception:");
	ATLogMessageFormat(@"Name:[%@]", exception.name);
	ATLogMessageFormat(@"Reason:[%@]", exception.reason);

	ATLogError(@"Test case failed due to uncaught exception!");
	[[ATExceptionHandler sharedInstance] messCleaner];
    [[UIApplication sharedApplication] performSelectorOnMainThread:@selector(terminateWithSuccess) withObject:nil waitUntilDone:TRUE];
}

static ATExceptionHandler* s_instance = nil;

@implementation ATExceptionHandler

+(ATExceptionHandler*) sharedInstance
{
    if(!s_instance){
        s_instance = [[ATExceptionHandler alloc] init];
    }

    return s_instance;
}

-(void) setNeedsTeardown:(BOOL) b
{
    m_needsTeardown = b;
}



-(void) setupStrongErrorHandling{
#ifndef APPECKER_TRACE
	ATSay(@"Setup strong error handling!");
	NSSetUncaughtExceptionHandler(&handleException);
	signal(SIGABRT, sighandler);
	signal(SIGILL, sighandler);
	signal(SIGSEGV, sighandler);
	signal(SIGFPE, sighandler);
	signal(SIGBUS, sighandler);
	signal(SIGPIPE, sighandler);
    signal(SIGTERM, sighandler);
#endif
}

-(void) tearDownStrongErrorHandling{
#ifndef APPECKER_TRACE
    if(!m_needsTeardown)
        return;

	ATSay(@"Teardown strong error handling!");

	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
    signal(SIGTERM, SIG_DFL);

    m_needsTeardown = NO;
#endif
}

-(void) setCrashDelegate:(id<AppeckerCrashHandler>) delegate
{
    m_crashDelegate = delegate;
}

-(void) cleanEnv
{
    if(!m_needsCleanEnv)
        return;

    m_needsCleanEnv = NO;
    if([ATCaseRunner IsRunningCase]){
        [ATCaseRunner TearDownCurCase];
        [ATCaseRunner DoCleanUp];
    }
}

-(void) messCleaner
{
    //This means another exception occurred during the process of calling m_crashDelegate
    if(m_onUserCrashFlow)
    {
        [self cleanEnv];
        [self tearDownStrongErrorHandling];
        return;
    }

    if(m_crashDelegate && [m_crashDelegate conformsToProtocol:@protocol(AppeckerCrashHandler)])
    {
        ATSay(@"Now perform user defined crash action");
        m_onUserCrashFlow = YES;
        [m_crashDelegate onCrash];
        m_onUserCrashFlow = NO;
    }

    [self cleanEnv];

    [self tearDownStrongErrorHandling];

}

-(id) init
{
    if(self = [super init])
    {
        m_needsTeardown = YES;
        m_crashDelegate = nil;
        m_onUserCrashFlow = NO;
        m_needsCleanEnv = YES;
    }

    return self;
}

@end
