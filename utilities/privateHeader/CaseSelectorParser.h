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

@interface SelectedCase : NSObject {
    NSString * caseID;
    int times;
}

@property (nonatomic, retain) NSString * caseID;
@property (nonatomic, assign) int times;
@end


@interface SelectedClass : NSObject {
    NSString * testClassName;
    NSMutableArray *selectedCases;
    int times;
}

@property (nonatomic, retain) NSString * testClassName;
@property (nonatomic, retain) NSMutableArray *selectedCases;
@property (nonatomic, assign) int times;
@end


@interface CaseSelectorParser : NSObject <NSXMLParserDelegate> {
    NSMutableArray *testClasses;
    NSMutableString *currentProperty;
    SelectedCase *currentCase;
    SelectedClass *currentClass;
    NSDictionary *currentClassAttributes;
    NSDictionary *currentCaseAttributes;
}

@property (nonatomic, retain) NSMutableArray *testClasses;
@property (nonatomic, retain) NSMutableString *currentProperty;
@property (nonatomic, retain) SelectedClass *currentClass;
@property (nonatomic, retain) SelectedCase *currentCase;
@property (nonatomic, retain) NSDictionary *currentClassAttributes;
@property (nonatomic, retain) NSDictionary *currentCaseAttributes;

-(void)parseCaseSelector:(NSData *)data parseError:(NSError **)err;

@end
