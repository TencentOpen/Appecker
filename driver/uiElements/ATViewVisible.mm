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

#import "ATViewPrivate.h"
#import "AppeckerContextWrapper.h"

@implementation UIView ( ATViewVisible )
-(BOOL) isInScreenBound
{
    CGRect initialFrame;
    initialFrame.origin.x = 0.0f;
    initialFrame.origin.y = 0.0f;
    initialFrame.size = self.bounds.size;

    CGRect finalFrame;

    if([self isKindOfClass:[UIWindow class]])
        finalFrame = initialFrame;
    else
        finalFrame = [self getViewFrameInAncestorView:[self atfWindow]];

    CGRect scrBounds = [[UIScreen mainScreen] bounds];

    if(CGRectIntersectsRect(scrBounds, finalFrame))
        return YES;

    return NO;
}

-(BOOL) atfTransparent
{

    AppeckerContextWrapper* contextWrapper = [[AppeckerContextWrapper alloc] initWithUIView:self];

    [self.layer renderInContext:contextWrapper.context];


    BOOL b = contextWrapper.isTransparent;

    [contextWrapper release];

    return b;
}

-(BOOL) atfVisible
{
    if(![self isKindOfClass:[UIWindow class]])
        if(self.window == nil)
            return NO;


    if(![self isInScreenBound])
        return NO;

    if(self.hidden)
        return NO;

    if(self.alpha == 0.0f)
        return NO;

    int width = self.frame.size.width;
    int height =  self.frame.size.height;
    if(width == 0.0f || height == 0.0f)
        return NO;

    if([self atfTransparent])
        return NO;

    return YES;
}

-(BOOL) isVisibleOnScr
{
    UIView* currentView = self;

    while (YES) {

        //This should be the last view
        if([currentView isKindOfClass:[UIWindow class]])
            return YES;

        if(currentView.superview == nil)
            return NO;

        NSEnumerator* enumerator = [currentView.superview.subviews reverseObjectEnumerator];
        UIView* view = nil;

        CGRect myRect = [currentView.window convertRect:currentView.bounds fromView:currentView];

        while(view = [enumerator nextObject])
        {
            if(view == currentView)
                break;

            if(![view atfVisible])
                continue;

            CGRect rect = [currentView.window convertRect:view.bounds fromView:view];
            if(CGRectContainsRect(rect, myRect)) //this view is covered by a sibling view with higher z-order
                return NO;
        }

        currentView = currentView.superview;

    }

#ifdef APPECKER_TRACE
    [NSException raise:@"Bad path" format:@"Should never reach here!"];
#endif

    return NO;

}


@end
