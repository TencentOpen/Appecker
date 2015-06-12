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

#import "ATMacroRec.h"
#import "TouchUtility.h"
#import "ATTextAlertView.h"
#import "ATMacroRecSwitch.h"
#import "ATHTMLAlertView.h"
#import "ATView.h"
#import "ATWindow.h"


static NSString* s_caseTemplate = @""
    "-(void) testcase_autoGen{\n"
    "NSArray* ary = nil;\n"
    "CGPoint pos = CGPointMake(0.0f, 0.0f);\n"
    "%@\n"
    "}\n";

static NSString* s_codeTemplate = @""
    "ary = [[UIWindow mainWindow] LocateViewsByClassName:@\"%@\"];\n"
    "ATFailIf([ary count] <= %d, @\"Incorrect view count, auto generated code will not work!\");\n"
    "pos = CGPointMake(%f, %f);\n"
    "[[ary objectAtIndex:%d] tapAt:pos];\n"
    "AppeckerWait(4.0f);\n\n";

ATMacroRec* s_instance = nil;

#define RECORD_TIMEOUT 3.0f
#define LONG_PRESS_TIMEOUT 0.8f

@implementation ATMacroRec

+(ATMacroRec*) sharedInstance
{
    if(!s_instance){
        s_instance = [[ATMacroRec alloc] init];
    }

    return s_instance;
}


-(id) init
{
    if (s_instance) {
        [NSException raise:@"Singleton!" format:@"You are initilizing a singleton!"];
    }

    if(self = [super init]){
        m_state = AtfRecordLocating;;
        m_code = [[NSMutableString alloc] init];
        m_ignore = NO;
        return self;
    }

    return nil;
}

-(void) dealloc
{
    [m_code release];
    [super dealloc];
}

-(int) viewOrder:(UIView*) view
{
    NSArray* ary = [[UIWindow mainWindow] LocateViewsByClassName:NSStringFromClass([view class])];

    NSUInteger cnt = [ary count];

    for(int i = 0; i < cnt; i ++){
        UIView* element = [ary objectAtIndex:i];

        if(element == view)
            return i;
    }

    return -1;
}


-(NSString*) getClickCodeOfTouch:(UITouch*) touch
{
    UIView* view = touch.view;

    NSString* viewClass = NSStringFromClass([view class]);
    int viewOrder = [self viewOrder:view];
    CGPoint pos = [touch locationInView:view];

    NSString* codeExcerpt = [NSString stringWithFormat:s_codeTemplate, viewClass, viewOrder, pos.x, pos.y, viewOrder];

    return codeExcerpt;
}

-(void) onGenCaseNormalPress:(UITouch*) touch
{

    NSString* code = [self getClickCodeOfTouch:touch];


    [m_code appendString:code];
}


-(void) showCaseCode{
    NSMutableString* caseCode = [[NSMutableString alloc] init];

    [caseCode appendFormat:s_caseTemplate, m_code];

    ATTextAlertView* alert = [[ATTextAlertView alloc] initWithTitle:@"TestCase" message:caseCode];

    [alert setDismissAction:@selector(onCodeViewClose) withTarget:self];

    [alert show];

    [alert release];

    [caseCode release];

}

-(NSString*) getLineOfView:(UIView*) view fromTree:(NSString*)tree
{
    NSArray* ary = [tree componentsSeparatedByString:@"\n"];
    NSString* addr = [NSString stringWithFormat:@"0x%x", view];

    for(NSString * line in ary){
        NSRange range;
        range = [line rangeOfString:addr];
        if(range.location != NSNotFound){
            return line;
        }
    }

    return nil;
}

-(NSString*) getHTMLTree:(NSString*) tree view:(UIView*) view
{
    NSString* srcLine = [self getLineOfView:view fromTree:tree];

    srcLine = [srcLine stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp"];

    tree = [tree stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp"];

    NSString* dstLine = [NSString stringWithFormat:@"<font color=red>%@</font>", srcLine];

    NSString* res = [tree stringByReplacingOccurrencesOfString:srcLine withString:dstLine];

    res = [res stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];

    return res;
}



-(void) restoreLocatingState
{
    m_state = AtfRecordLocating;
}

-(void) onShowingLocatingHelpEnd
{
    [self performSelector:@selector(restoreLocatingState) withObject:nil afterDelay:0.2];
}

-(UIView*) findBestViewByPos:(CGPoint) pos inView:(UIView*) rootView
{
    NSMutableArray* views = [[NSMutableArray alloc] init];

    [rootView flattenViewTreeToArray:views];

    UIView* bestView = rootView;
    CGFloat bestArea = CGFLOAT_MAX;

    for(UIView* view in views){
//        if(![UIWindow IsViewVisible:view])
//            continue;
        if(view == rootView)
            continue;

        CGRect rect = [view getViewFrameInAncestorView:rootView];

        if(CGRectContainsPoint(rect, pos)){
            CGFloat area = view.bounds.size.width * view.bounds.size.height;

            if(area < bestArea){
                bestView = view;
                bestArea = area;
            }
        }
    }

    [views release];

    return bestView;
}

-(UIView*) getBestView:(UITouch*) touch
{
    UIView* view = touch.view;

    if(view == nil)
        return nil;

    CGPoint pos = [touch locationInView:view];

    return [self findBestViewByPos:pos inView:view];
}

-(void) showLocatingHelp:(UITouch*) touch
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    UIWindow* win = touch.window;
    UIView* bestView = [self getBestView:touch];

    if(!bestView)
        return;

    NSString* tree = [win getTree];

    NSString* htmlTree = [self getHTMLTree:tree view:bestView];

    ATHTMLAlertView* alert = [[ATHTMLAlertView alloc] initWithTitle:@"View Tree" message:htmlTree];

    m_state = AtfRecordOffLine;

    [alert setDismissAction:@selector(onShowingLocatingHelpEnd) withTarget:self];

    [alert show];

    [alert release];

    [pool release];
}

-(void) onCodeViewClose
{
    [[ATMacroRecSwitch sharedInstance] show];
    [m_code setString:@""];

    m_state = AtfRecordLocating;
}

-(void) startCaseRec
{
    m_state = AtfRecordGenCase;
    [[ATMacroRecSwitch sharedInstance] hide];
}

-(void) stopCaseRec
{
    m_state = AtfRecordOffLine;

    [self showCaseCode];
}

-(void) watchForGenCaseTimeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopCaseRec) object:nil];
	[self performSelector:@selector(stopCaseRec) withObject:nil afterDelay:RECORD_TIMEOUT];
}

-(void) watchForLocatingLongPress:(UITouch*) touch
{
    if(touch.phase == UITouchPhaseBegan){
        [self performSelector:@selector(showLocatingHelp:) withObject:touch afterDelay:LONG_PRESS_TIMEOUT];
    }

    if(touch.phase == UITouchPhaseEnded){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLocatingHelp:) object:touch];
    }
}

-(void) onTouchEvent:(UIEvent*) touchEvent
{
    if(m_state == AtfRecordOffLine)
        return;

    NSString* eventName = NSStringFromClass([touchEvent class]);

    if(![eventName isEqualToString:@"UITouchesEvent"])
        return;

    NSUInteger touchCnt = [[touchEvent allTouches] count];

    if(touchCnt != 1)
        return; //Ignore too complex touch

    UITouch* touch = [[touchEvent allTouches] anyObject];


    if(m_state == AtfRecordLocating && touch.view != [ATMacroRecSwitch sharedInstance])
        [self watchForLocatingLongPress:touch];

    if(touch.phase == UITouchPhaseMoved){//Wipe is not handled by design
        m_ignore = YES;
        return;
    }

    if(touch.phase == UITouchPhaseEnded){
        if(m_ignore){
            m_ignore = NO;
            return;
        }

        if(m_state == AtfRecordGenCase)
            [self onGenCaseNormalPress:touch];

    }

    if(m_state == AtfRecordGenCase)
        [self watchForGenCaseTimeout];
}


@end



