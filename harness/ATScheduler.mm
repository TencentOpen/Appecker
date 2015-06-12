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

#import "ATScheduler.h"
#import "ATLogger.h"
#import "ATLauncher.h"
#import "ATCasesAssembler.h"
#import "CaseSelectorParser.h"
#import "ATTestCase.h"
#import "ATTestClass.h"


@implementation ATScheduler

+(BOOL) runCaseSpecifiedByCmdParameters:(ATCaseRunner *) caseRunner{
    NSString * caseId = [ATLauncher cmdParam:@"caseId"];
    if(nil == caseId){
        return NO;
    }


    NSDictionary* allCases = [[ATCasesAssembler sharedInstance] getAllCases];
    ATTestCase * testCase = [allCases objectForKey:caseId];
    if(testCase != nil){
        NSArray * cases = [NSArray arrayWithObject:testCase];
        [caseRunner runCases: cases withTargetClass:testCase.testClass];
    }
    else{
        ATLogWarningFormat(@"Test case not found: %@", caseId);
    }
    return YES;
}


+(BOOL) runCasesInConfigureation:(ATCaseRunner *) caseRunner{

    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CaseToRun" ofType:@"xml"]];
    CaseSelectorParser *parser = [[[CaseSelectorParser alloc] init] autorelease];
    [parser parseCaseSelector:data parseError:nil];
    if([parser.testClasses count]  == 0){
        return NO;
    }


    for(SelectedClass *classToRun in parser.testClasses)
    {
        ATTestClass * testCaseClass = [[ATCasesAssembler sharedInstance].testClassSet objectForKey:classToRun.testClassName];

        if(testCaseClass == NULL)
        {
            ATLogWarningFormat(@"Test class not found: %@", classToRun.testClassName);
            continue;
        }

        NSMutableArray * casesToRun = [NSMutableArray arrayWithCapacity:10];

        if([classToRun.selectedCases count] == 0)
        {
            //if no case selected, run all the cases

            [testCaseClass findAllTestCases];
            [casesToRun addObjectsFromArray:[testCaseClass.testCases allValues]];

        }
        else
        {
            for(SelectedCase *sCase  in classToRun.selectedCases)
            {
                ATTestCase* testCase = [testCaseClass.testCases objectForKey:sCase.caseID];
                if(testCase == nil){
                    ATLogWarningFormat(@"Test case not found: %@", sCase.caseID);
                    continue;
                }

                for(int k=0; k < sCase.times; k++)
                {
                    [casesToRun addObject:testCase];
                }
            }
        }

        if([casesToRun count] > 0){
            for(int i=0; i< classToRun.times; i++){
                [caseRunner runCases:casesToRun withTargetClass:testCaseClass.testClass];
            }
        }

    }
    return YES;
}

+(void) traverse:(ATCaseRunner *)caseRunner{

    // run the case specified by cmd line parameters only, if it does exist
    if([self runCaseSpecifiedByCmdParameters: caseRunner])
        return;

    // if there are cases configured in config files, run them and exit
    if([self runCasesInConfigureation: caseRunner]){
        [caseRunner.jobSummary writeJobSummary];
        return;
    }

    //run all the cases
    for(id aKey in [ATCasesAssembler sharedInstance].testClassSet){
        ATTestClass * testClass = [[ATCasesAssembler sharedInstance].testClassSet objectForKey:aKey];
        NSArray * cases = [testClass.testCases allValues];
        [caseRunner runCases: cases withTargetClass: testClass.testClass];
    }
    [caseRunner.jobSummary writeJobSummary];
}

@end

