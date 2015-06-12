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

#import "Appecker.h"
#import "AppeckerTraceManager.h"
#import "ATView.h"
#import "ATViewPrivate.h"

static AppeckerTraceManager* s_instance = nil;

@implementation AppeckerTraceManager

@synthesize maxStep = m_maxStep;
@synthesize autoTrace = m_autoTrace;
@synthesize traceMode = m_traceMode;
@synthesize operationCounter = m_operationCounter;
@synthesize totalScrCapCounter = m_totalScrCapCounter;

+(AppeckerTraceManager*) sharedInstance;
{
    if(!s_instance)
        s_instance = [[AppeckerTraceManager alloc] init];
    return s_instance;
}

-(id) init
{
    if(self = [super init]){
        m_maxStep = 10;
        m_autoTrace = YES;
        m_counter = 0;
        m_traceMode = NO;
        m_operationCounter = 0;
        m_totalScrCapCounter = 0;
        m_autoTraceDir = [self getDateString];
        m_allImgPath = [[NSMutableArray alloc] init];
        m_allTxtPath = [[NSMutableArray alloc] init];
    }

    return self;
}

-(NSString*) getDateString
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];

    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss"];
    NSString* timeStr = [dateFormatter stringFromDate:[NSDate date]];

    [dateFormatter release];

    return timeStr;
}

-(void) incOpCounter;
{
    m_operationCounter ++;
}

-(void) incTotalScrCapCounter;
{
    m_totalScrCapCounter ++;
}

-(NSUInteger) autoScrCapCounter
{
    if(!self.traceMode)
        return 0;

    return m_operationCounter;
}

-(NSUInteger) manualScrCapCounter
{
    if(self.traceMode)
        return m_totalScrCapCounter - m_operationCounter;

    return m_totalScrCapCounter;
}


-(void) dealloc
{
    [m_allImgPath release] , m_allImgPath = nil;
    [m_allTxtPath release] , m_allTxtPath = nil;

    [super dealloc];
}

-(void) deleteFile:(NSString*) path
{
    NSFileManager* mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:path error:nil];
}

-(void) clean:(NSMutableArray*) pathAry
{
    while ([pathAry count] > m_maxStep) {
        NSString* path = [pathAry objectAtIndex:0];
        [self deleteFile:path];
        [pathAry removeObjectAtIndex:0];
    }
}

-(void) onBeginTouch:(UIView*) view
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [self incOpCounter];

    if(!self.traceMode)
    {
        [pool release];
        return;
    }
    NSString* tag = nil;
    NSString* dir = nil;

    if(self.autoTrace){
        tag = [NSString stringWithFormat:@"%d", m_counter++];
        dir = m_autoTraceDir;
    }else
    {
        tag = self.manualTag;
        dir = self.manualDir;
    }


    NSString* imgPath;
    if([view isKindOfClass:[UIWindow class]])
        imgPath  = [view captureView:tag dir:dir];
    else
        imgPath = [[view atfWindow] captureView:tag dir:dir];

    NSString* txtPath = [view savePrintTree:tag dir:dir];

#ifndef APPECKER_TRACE
    if(imgPath){
#endif
        [m_allImgPath addObject:imgPath];
#ifndef APPECKER_TRACE
    }
#endif

#ifndef APPECKER_TRACE
    if(txtPath){
#endif
        [m_allTxtPath addObject:txtPath];
#ifndef APPECKER_TRACE
    }
#endif

    [self clean:m_allImgPath];
    [self clean:m_allTxtPath];

    [pool release];
}

@end
