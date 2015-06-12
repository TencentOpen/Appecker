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

#import "ATCasesAssembler.h"
#import "ATTestCase.h"
#import "ATTestClass.h"
#import "TestClassProtocol.h"

bool isTestClass(Class classType){

    if(!class_conformsToProtocol(classType, @protocol(TestClass)))
    {
        Class superClass = class_getSuperclass(classType);
        if(nil == superClass){
            return NO;
        }
        return isTestClass(superClass);
    }
    return YES;
}


@implementation ATCasesAssembler

static ATCasesAssembler *sharedCaseAssembler = nil;

-(NSDictionary *) testClassSet
{
    return _testClassSet;
}

-(void)findAllTestClasses
{
    int numClasses;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0 )
    {
        Class * classes = (Class *) malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for(int i=0; i < numClasses; i++)
        {
            Class classType = classes[i];
            if(isTestClass(classType))
            {
                NSString *className = NSStringFromClass(classType);
                ATTestClass *testClass = [ATTestClass testClassWithType:classType withDescription:className];
                [_testClassSet setObject:testClass forKey:className];
            }
        }
        free(classes);
    }
}

+ (ATCasesAssembler *)sharedInstance
{
    return sharedCaseAssembler;
}

+(void)releaseSharedInstance{
    if(sharedCaseAssembler != nil){
        [sharedCaseAssembler release];
        sharedCaseAssembler = nil;
    }
}

+(ATCasesAssembler *)createSharedInstance{
    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    @try{
        [ATCasesAssembler releaseSharedInstance];
        sharedCaseAssembler = [[ATCasesAssembler alloc] init];
    }
    @finally{
        [autoreleasePool release];
    }
    return sharedCaseAssembler;
}

-(id)init
{
    self = [super init];

	if(self != nil)
    {
        _testClassSet = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self findAllTestClasses];
    }
    return self;
}

-(void)dealloc
{
    [_testClassSet release];
    [super dealloc];
}

-(NSDictionary *)getAllCases{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:50];
    for(ATTestClass *testClass in [self.testClassSet objectEnumerator]){
        for(ATTestCase *testCase in [testClass.testCases objectEnumerator]){
            [dict setObject:testCase forKey: testCase.testCaseID];
        }
    }
    return dict;
}

@end
