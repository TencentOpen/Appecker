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

#define ATSay(format,...) NSLog(@"Appecker:%@", [NSString stringWithFormat:format, ##__VA_ARGS__]);



typedef enum{
    TEError = 0,
    TEWarning = 1,
    TEInfomation = 2,
    TEStartTest = 3,
    TEEndTest = 4,
}TraceEventType;


typedef enum {
    TRPassed = 0,
    TRWarning,
    TRFailed,
    TRBlocked,
    TRSkipped,
}ATTestResult;

void ATLogMessage(NSString* message);
void ATLogWarning(NSString* message);
void ATLogError(NSString* message);

void ATLogMessageFormat(NSString* format,...);
void ATLogWarningFormat(NSString* format,...);
void ATLogErrorFormat(NSString* format,...);


void ATLogIfAreEqual(NSString* expected, NSString* actual, NSString* message);
void ATLogIfAreEqualInt(int expected, int actual, NSString* message);
void ATLogIfAreEqualStr(NSString* expected, NSString* actual, NSString* message);
void ATLogIfAreEqualBOOL(BOOL expected, BOOL actual, NSString* message);

void ATLogIfAreBelowInt(int standard, int actual, NSString* message);
void ATLogIfAreBelowEqualInt(int standard, int actual, NSString* message);



@interface ATLogger : NSObject {
    NSFileHandle *fileHandle;
    ATTestResult _result;
}

+(ATLogger*) sharedInstance;
+(void)createSharedInstance:(NSString *) fileName underFolder:(NSString *) folderPath;
+(void)releaseSharedInstance;
-(void)logError:(NSString *) message;
-(void)logWarning:(NSString *) message;
-(void)logInfomation:(NSString *) message;
-(void)logStartTest:(NSString *) caseId;
-(ATTestResult)logEndTest:(NSString *) caseId;
-(ATTestResult)logEndTest:(NSString *) caseId withResult:(ATTestResult) result;
-(ATTestResult)caseResult;
@end
