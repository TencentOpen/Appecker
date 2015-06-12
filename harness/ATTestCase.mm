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

#import "ATTestCase.h"


@implementation ATTestCase


@synthesize testClass;
@synthesize method;
@synthesize testCaseID;
@synthesize testCaseName;
@synthesize testCaseAuthor;
@synthesize testCaseDescription;

+(id) testCaseWithClass:(Class)testClass Selector:(SEL) selector Id:(NSString *)caseId Name:(NSString *)caseName Author:(NSString *) caseAuthor Description:(NSString *)description{
    return [[[[self class] alloc]
             initWithClass:testClass
             Selector:selector
             Id:caseId
             Name:caseName
             Author:caseAuthor
             Description: description]
            autorelease];
}

+(id) testCaseWithId:(NSString *)caseId Name:(NSString *)caseName Author:(NSString *) caseAuthor Description:(NSString *)description
{
    return [[[[self class] alloc]
             initWithClass:NULL
             Selector:NULL
             Id:caseId
             Name:caseName
             Author:caseAuthor
             Description: description]
            autorelease];
}

-(id)initWithClass:(Class)testClassType Selector:(SEL)methodSelector Id:(NSString *)caseID Name:(NSString *)caseName Author:(NSString *)caseAuthor Description:(NSString *)caseDescription
{
    self = [super init];
    if(self != nil)
    {
        self.testClass = testClassType;
        self.method = methodSelector;
        self.testCaseID = caseID;
        self.testCaseName = caseName;
        self.testCaseAuthor = caseAuthor;
        self.testCaseDescription = caseDescription;
    }
    return self;
}

-(bool)isEqualTo:(ATTestCase *)testCaseToCompare
{
    return [self.testCaseID isEqualToString:testCaseToCompare.testCaseID];
}

-(void)dealloc
{
    //[testClass release];
    [self.testCaseID release];
    [self.testCaseName release];
    [self.testCaseAuthor release];
    [self.testCaseDescription release];

    [super dealloc];
}

@end
