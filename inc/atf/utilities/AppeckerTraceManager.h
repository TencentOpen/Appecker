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

@interface AppeckerTraceManager : NSObject
{
    NSUInteger m_maxStep;
    NSUInteger m_counter;
    BOOL m_autoTrace;
    BOOL m_traceMode;
    NSString* m_autoTraceDir;
    NSUInteger m_operationCounter;
    NSUInteger m_totalScrCapCounter;
    NSString* m_manualTag;
    NSString* m_manualDir;
    NSMutableArray* m_allImgPath;
    NSMutableArray* m_allTxtPath;
}

+(AppeckerTraceManager*) sharedInstance;
@property (nonatomic) NSUInteger maxStep;
@property (nonatomic) BOOL autoTrace;
@property (nonatomic) BOOL traceMode;
@property (nonatomic, retain) NSString* manualTag;
@property (nonatomic, retain) NSString* manualDir;
@property (readonly) NSUInteger operationCounter;
@property (readonly) NSUInteger manualScrCapCounter;
@property (readonly) NSUInteger totalScrCapCounter;
@property (readonly) NSUInteger autoScrCapCounter;

@end
