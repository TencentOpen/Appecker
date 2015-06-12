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

#import <Foundation/Foundation.h>
#import "../utilities/ATLogger.h"

@interface Summary : NSObject
{
    int pass;
    int failure;
    int total;
    int reRun;
    int rePass;
    int reFail;

    NSMutableArray *testJobCollection;

}
@property (nonatomic, assign) int pass;
@property (nonatomic, assign) int failure;
@property (nonatomic, assign) int total;
@property (nonatomic, assign) int reRun;
@property (nonatomic, assign) int rePass;
@property (nonatomic, assign) int reFail;
@property (nonatomic, retain) NSMutableArray *testJobCollection;
-(id)init;


@end

@interface TestJob : NSObject
{
@public
    NSString * jobID;
    NSString * jobDescription;
    NSString * jobResult;

}
@property (nonatomic, retain) NSString *jobID;
@property (nonatomic, retain) NSString *jobDescription;
@property (nonatomic, retain) NSString *jobResult;
-(id)init;
@end

@interface ATJobSummary : NSObject {

    Summary *jobSummary;
    bool reRunJobs;
}

-(id)init;

-(void)reRunCases:(int)count;
-(void)totalCases;
-(int)getPassed;
-(int)getFailed;
-(void)addItemToSummary:(NSString *)jobID jobDescription:(NSString *)description jobResult:(ATTestResult)result;
-(void)updateReRunPassFailCounter;
-(int)getJobCount;
-(void)writeJobSummary;

@end
