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

#import "ATWindow.h"
#import "ATView.h"

@implementation UIWindow (ATWindow )

+(NSArray*) getallWindow
{
    NSArray* windows = [[UIApplication sharedApplication] windows];
    return windows;

}

+(void*) printall
{
    NSArray* windows = [[UIApplication sharedApplication] windows];
    
    for(UIWindow* win in windows)
    {
        
        [win printTree];
    }
}

+(UIWindow*) GetlastWindow:(CGPoint) pos considerPos:(BOOL) considerPos
{
    NSArray* windows = [[UIApplication sharedApplication] windows];
    UIWindow* topMostWin = nil;
    UIWindow* lastWin = nil;
    for(UIWindow* win in windows)
    {
        if(![win atfVisible])
            continue;
        if( considerPos && ![win containsPos:pos])
            continue;
        if(topMostWin == nil){
            topMostWin = win;
            continue;
        }
        if(topMostWin.windowLevel <= win.windowLevel)
            topMostWin = win;
    }
    for(UIWindow* win1 in windows)
    {
        if(win1.windowLevel==topMostWin.windowLevel-1)
        {
            lastWin=win1;
             break;
        }
    }
    return lastWin;
}

+(UIWindow*) lastWindow
{
    return [self GetlastWindow:CGPointMake(0.0f, 0.0f) considerPos:NO];
}

+(UIWindow*) GetTopMostWindow:(CGPoint) pos considerPos:(BOOL) considerPos
{
    NSArray* windows = [[UIApplication sharedApplication] windows];

    UIWindow* topMostWin = nil;

    for(UIWindow* win in windows)
    {
        if(![win atfVisible])
            continue;

        if( considerPos && ![win containsPos:pos])
            continue;

        if(topMostWin == nil){
            topMostWin = win;
            continue;
        }

        if(topMostWin.windowLevel <= win.windowLevel)
            topMostWin = win;
    }
    return topMostWin;
}

+(UIWindow*) TopMostWindow
{
    return [self GetTopMostWindow:CGPointMake(0.0f, 0.0f) considerPos:NO];
}

+(void) TapAtScrPos:(CGPoint) pos
{

    UIWindow* topMostWin = [self GetTopMostWindow:pos considerPos:YES];

    [topMostWin tap];
}

+(UIWindowLevel) GetHighestWindowLevel
{
    UIWindowLevel max = 0.0f;
    NSArray* windows = [[UIApplication sharedApplication] windows];
    for(UIWindow* win in windows){
        if(win.windowLevel > max)
            max = win.windowLevel;
    }

    if(max < UIWindowLevelStatusBar)
        max = UIWindowLevelStatusBar;

    return max + 1.0f;
}

+(void) TapAtScrCenter;
{

    CGRect scr = [[UIScreen mainScreen] bounds];

    CGPoint pos;
    pos.x = scr.size.width / 2.0f;
    pos.y = scr.size.height / 2.0f;

    [self TapAtScrPos:pos];
}


+(id)mainWindow
{
    UIWindow* mainWin = nil;
    NSArray *wArray = [[UIApplication sharedApplication] windows];
    mainWin = [wArray objectAtIndex:0];

    return mainWin;
}

-(id)subviewControllerForView: (UIView *) view
{
    for(UIView *subview in [view subviews]){
        UIResponder *responder = [subview nextResponder];
        if([responder isKindOfClass:[UIViewController class]]){
            return responder;
        }
        else{
            id result = [self subviewControllerForView:subview];
            if(result != nil){
                return result;
            }
            else{
                continue;
            }
        }
    }
    return nil;
}
-(id)subviewController
{
    return [self subviewControllerForView: self];
}

+ (id)getViewFromOverlayWindowByClass:(Class)classType
{
    UIView *result = nil;


    NSArray *wArray = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in wArray)
    {
        if([window isKindOfClass:NSClassFromString(@"_UIAlertOverlayWindow")])
        {
            UIView * view = [window LocateViewByClass:classType];
            if(view != nil)
            {
                result = view;
                break;
            }
        }
    }

    return result;
}

+ (UIActionSheet *)actionSheet
{
    return [self getViewFromOverlayWindowByClass:[UIActionSheet class]];
}

+ (UIAlertView *)alertView
{
    return [self getViewFromOverlayWindowByClass:[UIAlertView class]];
}

+ (UIWindow *)activityIndicatorWindow
{
    UIWindow *result = nil;
    NSArray *wArray = [[UIApplication sharedApplication] windows];

    // start from index 1 to skip the main window
    for(int i = 1; i < [wArray count]; i++)
    {
        UIView *view = [[wArray objectAtIndex:i] LocateViewByClass:[UIActivityIndicatorView class]];
        if(view != nil)
        {
            UIWindow * w = [wArray objectAtIndex:i];
            if(!w.hidden && w.alpha != 0 && w.opaque){
                result = [wArray objectAtIndex:i];
                break;
            }
        }
    }

    return result;
}

+ (BOOL) tapAlertViewButtonWithTag:(int) tag
{
    if(tag ==0){
        return NO;
    }

    UIAlertView * alertView = [UIWindow alertView];
    if(alertView == nil){
        return NO;
    }

    UIButton * button = [alertView LocateViewByTag:tag];
    if(nil == button){
        return NO;
    }

    [button tap];
    return YES;
}

+ (void)printTree
{
    [[UIWindow mainWindow] printTree];
}
@end
