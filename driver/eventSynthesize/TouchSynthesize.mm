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

#import "TouchSynthesize.h"
#import "EventSynthesize.h"
#import "EventProxy.h"
#import "ATWindow.h"
#import "ATView.h"
#import "ATLogger.h"
#import "ATViewPrivate.h"
#import "UITouch.h"

@implementation UITouch (Synthesize)

-(id)initInView:(UIView *) view
{
    CGPoint pos = CGPointMake( view.frame.size.width * 0.5, view.frame.size.height * 0.5);
    return [self initInView:view withPosition: pos];

}

-(id)initInView:(UIView *)view withPosition:(CGPoint)pos
{
    return [self initInView:view withPosition:pos withTapCount:1 isFirstTouchForView:YES];
}

-(id)initInViewWithNoHitTest:(UIView *)view withPosition:(CGPoint)pos
{
    return [self initInView:view withPosition:pos withTapCount:1 isFirstTouchForView:YES doHitTest:NO];
}

-(id)initInView:(UIView *)view withPosition:(CGPoint)pos withTapCount:(int)tapCount isFirstTouchForView:(BOOL)isFirstTouch
{
    return [self initInView:view withPosition:pos withTapCount:tapCount isFirstTouchForView:isFirstTouch doHitTest:YES];
}

#ifdef IOS5_SPECIFIC
-(NSArray*) grFilter:(NSArray*) grInAry
{
    NSMutableArray* ary = [[[NSMutableArray alloc] init] autorelease];
    for(id elem in grInAry){
        NSString* className = NSStringFromClass([elem class]);
        if([className isEqualToString:@"UIGobblerGestureRecognizer"])
            continue;
        [ary addObject:elem];
    }

    return ary;
}
#endif

-(id)initInView:(UIView *)view withPosition:(CGPoint)pos withTapCount:(int)tapCount isFirstTouchForView:(BOOL)isFirstTouch doHitTest:(BOOL) doHitTest
{


    self = [super init];

    if(self != nil)
    {
        BOOL isWindow = [view isKindOfClass:[UIWindow class]];

        if(isWindow)
        {
            _locationInWindow = pos;
        }
        else {
            _locationInWindow = [[view atfWindow] convertPoint:pos fromView:view];
        }

        _tapCount = tapCount ;
        _previousLocationInWindow = _locationInWindow;

        UIView *target;
        if(![view isKindOfClass:NSClassFromString(@"UIRemoveControlTextButton")]
           && ![view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationControl")]
		   && doHitTest
		   )
        {
            if(isWindow)
            {
                target = [view hitTest:_locationInWindow withEvent:nil];
            }else
            {
                target = [[view atfWindow] hitTest:_locationInWindow withEvent:nil];
            }
        }
        else
        {
            target = view;
        }


        if(target == nil)
        {
            target = view;
        }

#ifdef APPECKER_TRACE
        ATLogMessageFormat(@"hittest actual view is: 0x%x", target);
#endif

        _view = [target retain];

        if(!isWindow)
            _window = [[view atfWindow] retain];
        else
            _window = [view retain];


        if(nil == _window)
        {
            _window = [[UIWindow mainWindow] retain];
        }
        _phase = UITouchPhaseBegan;

#ifdef IOS5_SPECIFIC
        _savedPhase = UITouchPhaseBegan;
#endif
        if(isFirstTouch){

            _touchFlags._firstTouchForView = 1;
        }
        else{

            _touchFlags._firstTouchForView = 0;
        }
        _touchFlags._isTap = 1;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];

		NSMutableArray *gestureRecognizers = [[NSMutableArray alloc] init];
		UIView *superview = target;
		while (superview) {
			if (superview.gestureRecognizers.count) {
#ifdef IOS5_SPECIFIC
				[gestureRecognizers addObjectsFromArray:[self grFilter:superview.gestureRecognizers]];
#else
   				[gestureRecognizers addObjectsFromArray:superview.gestureRecognizers];
#endif
			}

			superview = superview.superview;
		}

		_gestureRecognizers = gestureRecognizers;

        _pathIndex = 2;
        _pathIdentity = 2;
        _pathMajorRadius = 1;

    }
    return self;

}


-(void)changeToPhase: (UITouchPhase)phase
{
    _phase = phase;
    _timestamp = [NSDate timeIntervalSinceReferenceDate];
}

//
// setPhase:
//
// Setter to allow access to the _locationInWindow member.
//
- (void)setLocationInWindow:(CGPoint)location
{
    _previousLocationInWindow = _locationInWindow;
    _locationInWindow = location;
    _timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end
