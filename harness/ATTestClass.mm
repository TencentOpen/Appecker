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

#import "ATTestClass.h"
#import "ATTestCase.h"

@implementation ATTestClass

@synthesize testClass = _testClass;
@synthesize testClassDescription = _testClassDescription;
@synthesize testCases = _testCases;


-(void)findAllTestCases
{
    NSString * className = NSStringFromClass(self.testClass);

    NSDictionary *caseInfoList = nil;
    if([_testClass respondsToSelector:@selector(registerCaseInformation)])
    {
        caseInfoList = [_testClass performSelector:@selector(registerCaseInformation)];
    }
    NSUInteger methodCount = 0;
    Method *methodList = class_copyMethodList(self.testClass, &methodCount);
    if(methodList != NULL)
    {
        for(int i = 0 ; i<methodCount; ++i)
        {
            SEL methodSelector = method_getName(methodList[i]);
            const char* methodString = sel_getName(methodSelector);
            NSString * methodName = [NSString stringWithCString:methodString encoding:NSUTF8StringEncoding];
            int len = [methodName length];
            if(len > 9 && [[methodName substringToIndex:9] isEqualToString:@"testcase_"]){
                NSString *testCaseId = [methodName substringFromIndex:9];
                ATTestCase *registedCase = nil;
                if(caseInfoList)
                {
                    registedCase = [caseInfoList objectForKey:testCaseId];
                }
                testCaseId = [NSString stringWithFormat:@"%@.%@", className, testCaseId];
                NSString *testCaseName = registedCase.testCaseName;
                NSString *testCaseAuthor = registedCase.testCaseAuthor;
                NSString *testCaseDescription = registedCase.testCaseDescription;
                ATTestCase *testCase = [ATTestCase testCaseWithClass:self.testClass Selector:methodSelector Id:testCaseId Name:testCaseName Author:testCaseAuthor Description:testCaseDescription];
                [_testCases setObject:testCase forKey:testCaseId];
            }
        }
    }
    free(methodList);
}

+(id)testClassWithType:(Class) testClassType withDescription:(NSString *) description{
    return [[[[self class] alloc] initWithType:testClassType withDescription:description] autorelease];
}

-(id)initWithType:(Class)testClassType withDescription:(NSString *)classDescription
{
    self = [super init];
    if(self != nil)
    {
        self.testClass = testClassType;
        self.testClassDescription = classDescription;
        _testCases = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self findAllTestCases];
    }
    return self;
}

-(void)dealloc
{
    [self.testClassDescription release];
    [_testCases release];
    [super dealloc];
}

@end
