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

#import "ATLauncher.h"
#import "ATLogger.h"
#import "ATCaseRunner.h"
#import "ATCasesAssembler.h"
#import "ATScheduler.h"
#import "ATTestClass.h"
#import "ATTestCase.h"
#import "ATCaseFilter.h"
#import "ATExceptionHandler.h"
#import "ATExceptionHandlerPrivate.h"

static NSMutableDictionary * cmdParameters = nil;


@implementation ATLauncher

+(void) setupWithArgs:(const char**)argv count:(int) argc{
	[[ATExceptionHandler sharedInstance] setupStrongErrorHandling];

    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    @try{
        cmdParameters = [[NSMutableDictionary alloc] init];
        for(int i=0; i<argc; ++i){
            if('-' == argv[i][0] && i + 1 < argc ){
                NSString *argkey = [NSString stringWithCString:(argv[i] + 1) encoding:NSUTF8StringEncoding];
                NSString *argValue = [NSString stringWithCString:argv[++i] encoding:NSUTF8StringEncoding];
                ATSay(@"key: %@, value: %@", argkey, argValue);
                [cmdParameters setValue:argValue forKey:[argkey lowercaseString]];
            }
        }

        NSString *logFile = [cmdParameters valueForKey:@"logfile"];
        NSString *logPath = [cmdParameters valueForKey:@"logpath"];
        [ATLogger createSharedInstance:logFile underFolder:logPath];

        [ATCasesAssembler createSharedInstance];
    }
    @finally{
        [autoreleasePool release];
    }
}

+(void) tearDown{
    [cmdParameters release];
    [ATLogger releaseSharedInstance];
    [ATCasesAssembler releaseSharedInstance];
	[[ATExceptionHandler sharedInstance] tearDownStrongErrorHandling];
}

+(NSString *) cmdParam:(NSString *) parameterName{
    return [cmdParameters objectForKey:[parameterName lowercaseString]];
}

+(void) run{
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    ATLogMessage(@"Launcher started...");


    @try
    {
        NSString * casesFile = [self cmdParam:@"outputCases"];
        if(nil == casesFile) {
            //run test cases
            ATCaseRunner * runner = [[[ATCaseRunner alloc] init] autorelease];
            [ATScheduler traverse:runner];
        }
        else{
            //output case list to the given file
            NSString * caseFilterParameter = [cmdParameters valueForKey:@"filter"];
            NSString * classFiltersParameter = [cmdParameters valueForKey:@"class"];
            ATCaseFilter * caseFilter = [[ATCaseFilter alloc] initWithCaseFilter:caseFilterParameter classFilter:classFiltersParameter];
            [self writeCaseListToFile: casesFile withCaseFilter: caseFilter];
            [caseFilter release];
        }
    }
    @catch (id ex) {
        ATLogErrorFormat(@"Exception catched in launcher:%@", ex);
    }
    @finally {
        ATLogMessage(@"Launcher exited.");
        [autoreleasepool release];
        [[UIApplication sharedApplication] performSelectorOnMainThread:@selector(terminateWithSuccess) withObject:nil waitUntilDone:TRUE];
    }
}

+ (void) writeCaseListToFile: (NSString *) filePathName withCaseFilter: (ATCaseFilter *) caseFilter {
    ATLogMessageFormat(@"Writting case list into file: %@, case filter = %@", filePathName, caseFilter);

    NSMutableString *output = [NSMutableString stringWithCapacity:1024 * 5];
    for(ATTestClass *testClass in [[ATCasesAssembler sharedInstance].testClassSet objectEnumerator]){
        if(![caseFilter isClassMatches:NSStringFromClass([testClass testClass])]){
            continue;
        }
        for(ATTestCase *testCase in [testClass.testCases objectEnumerator]){
            if(![caseFilter isCaseMatches:testCase.testCaseID]){
                continue;
            }
            [output appendString: testCase.testCaseID];
            [output appendString:@"\n"];
        }
    }
    [output writeToFile:filePathName atomically:YES encoding:NSUTF8StringEncoding error: nil];
}

+(BOOL) isRunningFromCmdLine
{
	return [ATLauncher cmdParam:@"caseId"] != nil;
}

+(NSString*) getValueForParam:(NSString*) key
{
    return [cmdParameters valueForKey:key];
}

@end

