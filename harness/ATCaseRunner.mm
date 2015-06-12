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

#import "ATCaseRunner.h"
#import "ATCasesAssembler.h"
#import "ATTestClass.h"
#import "ATLogger.h"
#import "ATException.h"
#import "ATWaitUtility.h"
#import <Foundation/NSException.h>


//Modified to catch some exceptions thrown by Obj-c runtime
//Attention:
//	Although, we tried very hard to catch all exceptions possibly occur,
//	unix kernel is lack of some ability which is known as SEH in winNT
//	kernel. So there is still a chance that a case can crash ungracefully,
//	and causing a buggy xml report produced.
//	Please be careful with your case, and don't do anything seriously wrong(e.g. access violation)!
//********Modification Begin*************//
static ATTestCase* s_curCase=nil;
static ATCaseRunner* s_curRunner=nil;
static id s_curTarget=nil;


static void _setCurTarget(id target)
{
	s_curTarget = target;
}

static id _getCurTarget()
{
	return s_curTarget;
}

static void _setCurCase(ATTestCase* curCase)
{
	s_curCase = curCase;
}

static ATTestCase* _getCurCase()
{
	return s_curCase;
}

static void _setCurRunner(ATCaseRunner* runner)
{
	s_curRunner = runner;
}

static ATCaseRunner* _getCurRunner()
{
	return s_curRunner;
}

static void _tearDownCase(id target)
{
    if(!_getCurCase())
        return;

	if([target respondsToSelector:@selector(teardownCase)])
	{
		ATTestCase* theCase = _getCurCase();
		ATLogMessage([NSString stringWithFormat:@"Tearing down test case: %@", theCase.testCaseID]);
		[target performSelector:@selector(teardownCase)];
	}
}

static void _doCleanUp()
{
    if(!_getCurCase())
        return;

	ATTestCase* theCase = _getCurCase();
	ATCaseRunner* runner = _getCurRunner();
	ATTestResult caseResult = [[ATLogger sharedInstance] logEndTest: theCase.testCaseID];
	[runner.jobSummary addItemToSummary:theCase.testCaseID jobDescription:theCase.testCaseDescription jobResult:caseResult];
}

//********Modification End*************//



@interface ATCaseRunner()

-(void) runCase:(ATTestCase *) theCase withTarget:(id)target;
-(void) runCaseInner:(ATTestCase *) theCase withTarget:(id)target;

@end


@implementation ATCaseRunner

@synthesize jobSummary;

+(bool) IsRunningCase
{
    return _getCurCase()!=nil;
}


+(ATTestCase*) GetCurCase
{
    return _getCurCase();
}

+(NSString*) GetCurCaseID
{
    return [[self GetCurCase] testCaseID];
}

-(void) _setupCriticalInfo:(ATTestCase*) theCase target:(id) target
{
	_setCurRunner(self);
	_setCurCase(theCase);
	_setCurTarget(target);
}

-(void) runCaseInner:(ATTestCase *) theCase withTarget:(id)target
{
	[self _setupCriticalInfo:theCase target:target];
    @try{
        if([target respondsToSelector:@selector(setupCase)])
        {
            ATLogMessage([NSString stringWithFormat:@"Setting up test case: %@", theCase.testCaseID]);
            [target performSelector:@selector(setupCase)];
        }

        [target performSelector:theCase.method];

    }
    @finally {
        _tearDownCase(target);
	}

}

+(void) DoCleanUp
{
	_doCleanUp();
}

+(void) TearDownCurCase
{
	_tearDownCase(_getCurTarget());
}


-(void)runCase:(ATTestCase*)theCase withTarget:(id)target {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    try{
        @try{
            [[ATLogger sharedInstance] logStartTest: theCase.testCaseID];
			[self runCaseInner:theCase withTarget:target];
            ATLogMessageFormat(@"Finishing test case %@", theCase.testCaseID);

        }
        @catch (ATException * exception) {
            ATLogError([exception description]);
        }
        @catch (NSObject * exception) {
            ATLogError([exception description]);
        }
        @finally {
            _doCleanUp();
        }
    }
    catch(...){
        ATLogError(@"Unknown C++ exception");
	}

    [pool release];
}

-(void)runCases:(NSArray *)cases withTargetClass:(Class) targetClass {

    id testClassInstance = [class_createInstance(targetClass, 0) init];
    const char * targetClassName = class_getName(targetClass);
    ATLogMessage([NSString stringWithFormat:@"Setup test class: %s", targetClassName]);
    if([testClassInstance respondsToSelector:@selector(setup)])
    {
        [testClassInstance performSelector:@selector(setup)];
    }
    for(ATTestCase *aCase in cases){
        AppeckerWait(2.0f);
        [self runCase:aCase withTarget:testClassInstance];
        AppeckerWait(2.0f);
    }

    if([testClassInstance respondsToSelector:@selector(teardown)])
    {
        [testClassInstance performSelector:@selector(teardown)];
    }
    ATLogMessage([NSString stringWithFormat:@"Tear down test class: %s", targetClassName]);
    [testClassInstance release];

    AppeckerWait(2.0f);
}


-(id)init{

    self = [super init];
    if(self != nil){
        jobSummary = [[ATJobSummary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [jobSummary release];
    [super dealloc];
}

@end
