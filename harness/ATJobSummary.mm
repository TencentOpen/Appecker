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

#import "ATJobSummary.h"

@implementation AppeckerSummary
@synthesize pass;
@synthesize failure;
@synthesize total;
@synthesize reRun;
@synthesize rePass;
@synthesize reFail;
@synthesize testJobCollection;
-(id)init
{
    self = [super init];
    if(self != nil)
    {
        self.pass = 0;
        self.failure = 0;
        self.total = 0;
        self.reRun = 0;
        self.rePass = 0;
        self.reFail = 0;
        self.testJobCollection = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [self.testJobCollection release];
    [super dealloc];
}

@end

@implementation TestJob

@synthesize jobID;
@synthesize jobDescription;
@synthesize jobResult;

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        self.jobID = [[NSString alloc] init];
        self.jobDescription = [[NSString alloc] init];
        self.jobResult = [[NSString alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [self.jobID release];
    [self.jobDescription release];
    [self.jobResult release];
    [super dealloc];
}

@end

@implementation ATJobSummary

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        jobSummary = [[AppeckerSummary alloc] init];
        reRunJobs = FALSE;
    }
    return self;
}

-(void)reRunCases:(int)count
{
    jobSummary.reRun = count;
    jobSummary.failure -= count;
    reRunJobs = TRUE;
}

-(void)totalCases
{
    jobSummary.total = [jobSummary.testJobCollection count];
}

-(int)getPassed
{
    return jobSummary.pass;
}

-(int)getFailed
{
    return jobSummary.failure;
}

-(void)addItemToSummary:(NSString *)jobID jobDescription:(NSString *)description jobResult:(ATTestResult)result
{
    TestJob *job = [[TestJob alloc] init];
    job.jobID = jobID;
    job.jobDescription = description;
    switch (result) {
        case TRPassed:

            job.jobResult = @"Passed";
            jobSummary.pass ++;
            if(reRunJobs)
            {
                jobSummary.rePass ++;
            }
            break;

        case TRFailed:
            job.jobResult = @"Failed";
            jobSummary.failure ++;
            if(reRunJobs)
            {
                jobSummary.reFail ++;
            }
            break;
        case TRWarning:
            job.jobResult = @"Warning";
            break;
        case TRSkipped:
            job.jobResult = @"Skipped";
            break;
        case TRBlocked:
            job.jobResult = @"Blocked";
            break;
        default:
            break;
    }

    [jobSummary.testJobCollection addObject:job];
    [job release];
}

-(void)updateReRunPassFailCounter
{
    reRunJobs = FALSE;
}

-(int)getJobCount
{
    return [jobSummary.testJobCollection count];
}

-(void)writeJobSummary
{

    ATSay(@"Total test cases runned: %d", [self getJobCount]);
    ATSay(@"Test cases passed: %d", jobSummary.pass);
    ATSay(@"Test cases failed: %d", jobSummary.failure);

    for(int i=0; i< [self getJobCount]; i ++)
    {
        TestJob * job = [jobSummary.testJobCollection objectAtIndex:i];
        ATSay(@"TestCaseID:%@       Description:%@          Result:%@",job.jobID, job.jobDescription, job.jobResult);
    }
}

-(void)dealloc
{
    [jobSummary release];
    [super dealloc];
}

@end
