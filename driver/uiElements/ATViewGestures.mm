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

#import "ATView.h"
#import "EventProxy.h"
#import "TouchSynthesize.h"
#import "EventSynthesize.h"
#import "VisibleTouch.h"
#import "ATUICommon.h"
#import "Appecker.h"
#import "ATWaitUtility.h"
#import "AppeckerTraceManager.h"
#import "AppeckerTraceManagerPrivate.h"
#import "ATWaitUtilityPrivate.h"
#import "AppeckerPrivate.h"

static UIEvent* s_lastEvent;

@implementation UIView ( ATViewGestures )

NSMutableArray* s_touchWidgetAry = nil;

-(void) addTouchWidget:(NSSet*) touches
{
    if(s_touchWidgetAry){
        [s_touchWidgetAry release];
        s_touchWidgetAry = nil;
    }

    s_touchWidgetAry = [[NSMutableArray alloc] init];

    for(UITouch* touch in touches){
        VisibleTouch* touchWidget = [[VisibleTouch alloc] initWithTouch:touch];
        [s_touchWidgetAry addObject:touchWidget];

        [touchWidget show];

        [touchWidget release];
    }
}

-(void) updateTouchWidget
{
	[s_touchWidgetAry makeObjectsPerformSelector:@selector(updatePosition)];
}

-(void) removeTouchWidget
{
    [s_touchWidgetAry[0] release];
    [s_touchWidgetAry makeObjectsPerformSelector:@selector(disappear)];

    [s_touchWidgetAry release];

    s_touchWidgetAry = nil;
}

- (void)beginTouchesInternal:(NSSet *)touches
{
    //It is important to hold a reference of the current UIView,
    //because many operations to it may cause it to be released! by mushuang 2012/3/5
    [self retain];


    [self addTouchWidget:touches];

    [[Appecker sharedInstance] onBeginTouch:self];
    [[AppeckerTraceManager sharedInstance] onBeginTouch:self];

	UIEvent *eventDown = [self _eventWithTouches:touches];
    [[UIApplication sharedApplication] sendEvent:eventDown];
    s_lastEvent = eventDown;
}

- (void)moveTouchesInternal:(NSSet *)touches
{
    [self updateTouchWidget];

	for(UITouch *touch in touches)
    {
        [touch changeToPhase:UITouchPhaseMoved];
    }

	[[UIApplication sharedApplication] sendEvent:s_lastEvent];

}

- (void)endTouchesInternal:(NSSet *)touches
{
    [self removeTouchWidget];

    for(UITouch *touch in touches)
    {
        [touch changeToPhase:UITouchPhaseEnded];
    }

    [[UIApplication sharedApplication] sendEvent:s_lastEvent];


    //Make sure to clear all touches in a UIEvent, or some reference to relevant UIView will not be release immediately
    //As a result, some views like UIWindow will not disappear as expected!
    [s_lastEvent _clearTouches];

    s_lastEvent = nil;

    //Release the reference previously held by Appecker in beginTouchesInternal
    //Please be sure this is the last step in the workflow! by mushuang 2012/3/5
    [self release];
}

-(void)beginTouches:(NSSet*)touches
{
    [self beginTouchesInternal: touches];
}

-(void)beginTouch:(UITouch*)touch
{

    NSSet *touches = [[NSMutableSet alloc] initWithObjects:&touch count:1];
    [self beginTouches:touches];
    [touches release];
}

-(void)endTouches:(NSSet*)touches
{
    [self endTouchesInternal: touches];
}

-(void)endTouch:(UITouch*)touch
{
	NSSet *touches = [[NSMutableSet alloc] initWithObjects:&touch count:1];
    [self endTouches:touches];
    [touches release];
}

- (void)moveTouches:(NSSet *)touches
{
    [self moveTouchesInternal: touches];
}

- (void)moveTouch:(UITouch *)touch to:(CGPoint)newPos
{
    NSSet *touches = [[NSMutableSet alloc] initWithObjects:&touch count:1];
    [touch setLocationInWindow: newPos];

    [self moveTouches:touches];

    [touches release];
}

- (void)moveTouch1:(UITouch *)touch1 to:(CGPoint)newPos1 touch2:(UITouch*)touch2 to:(CGPoint)newPos2
{
    NSSet *touches = [[NSMutableSet alloc] initWithObjects:touch1, touch2, nil];
    [touch1 setLocationInWindow: newPos1];
    [touch2 setLocationInWindow: newPos2];
    [self moveTouches:touches];
    [touches release];
}


-(void) tap
{
    CGPoint pos = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    [self tapAt: pos];
}

-(void) tapDirect
{
	CGPoint pos = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
	[self tapAtDirect:pos];
}

-(void) tapAtMiddleUpper
{
    [self tapAtPositionByRatioX:0.5 ratioY:0.2];
}

-(void) tapAtDirect:(CGPoint) pos
{
    [self tapAt:pos	withHitTest:NO];
}

-(void) tapAt:(CGPoint) pos
{
	[self tapAt:pos withHitTest:YES];
}

-(void) tapAt:(CGPoint)pos withHitTest:(BOOL) hitTest
{
	//todo: verify pos is in the frame of the view

	[self tapAtPos:pos for:0.2 doHitTest:hitTest];
}

-(void) tapAtPositionByRatioX:(float)ratioX ratioY:(float)ratioY
{
    CGPoint pos = CGPointMake(self.frame.size.width * ratioX, self.frame.size.height * ratioY);
    [self tapAt: pos];
}

-(CGPoint)CalculateNewPositionFrom:(CGPoint)pos1 to:(CGPoint)pos2 withFactor:(float)factor
{
    float x = pos1.x + (pos2.x - pos1.x) * factor;
    float y = pos1.y + (pos2.y - pos1.y) * factor;
    return CGPointMake(x, y);
}

-(void) moveTouch:(UITouch*)touch to:(CGPoint)pos2 in:(float)timeInSeconds{
    float eachMove = 0.1 / timeInSeconds;
    CGPoint originalPos = [touch  locationInView:[touch  window]];
    pos2 = [[touch window] convertPoint:pos2 fromView:[touch view]];

    for(float factor = eachMove; factor < 1.0; factor += eachMove){
        CGPoint newPos = [self CalculateNewPositionFrom:originalPos to:pos2 withFactor:factor];
        [self moveTouch:touch to:newPos];
        AppeckerWait(0.1f);
    }
    [self moveTouch:touch to:pos2];
}

-(void) moveTouch1:(UITouch*)touch1 to:(CGPoint)pos12
            touch2:(UITouch*)touch2 to:(CGPoint)pos22 in:(float)timeInSeconds{
    float eachMove = 0.1 / timeInSeconds;
    CGPoint orighnalPos1 = [touch1 locationInView:[touch1 window]];
    UIWindow* win1 = [touch1 window];
    UIWindow* win2 = [touch2 window];

    pos12 = [win1 convertPoint:pos12 fromView:[touch1  view]];
    CGPoint orighnalPos2 = [touch2 locationInView:win2];
    pos22 = [win2 convertPoint:pos22 fromView:[touch2 view]];
    for(float factor = eachMove; factor < 1.0; factor += eachMove){
        CGPoint newPos1 = [self CalculateNewPositionFrom:orighnalPos1 to:pos12 withFactor:factor];
        CGPoint newPos2 = [self CalculateNewPositionFrom:orighnalPos2 to:pos22 withFactor:factor];
        [self moveTouch1:touch1 to:newPos1 touch2:touch2 to:newPos2];
        AppeckerWait(0.1f);
    }
    [self moveTouch1:touch1 to:pos12 touch2:touch2 to:pos22];
}

-(void) touchAndMoveFrom:(CGPoint) pos1 to:(CGPoint) pos2 in:(float)timeInSeconds
{
    UITouch *touch = [[UITouch alloc] initInView:self withPosition:pos1];
    [self beginTouch: touch];
    [self moveTouch:touch to:pos2 in:timeInSeconds];
    [self endTouch: touch];
    [touch release];
}


-(void) tapCenterFor:(NSTimeInterval) holdTimeInSeconds
{
    CGPoint centerPos = [self atfGetCenter];
    [self tapAtPos:centerPos for:holdTimeInSeconds doHitTest:YES];
}

-(void) tapAtPos:(CGPoint)pos for:(NSTimeInterval)holdTimeInSeconds
{
    [self tapAtPos:pos for:holdTimeInSeconds doHitTest:YES];
}

-(void) tapAtPos:(CGPoint) pos for:(NSTimeInterval) holdTimeInSeconds doHitTest:(BOOL) hitTest
{
	UITouch *touch;
	if(!hitTest)
		touch = [[UITouch alloc] initInViewWithNoHitTest:self withPosition:pos];
	else
		touch = [[UITouch alloc] initInView:self withPosition:pos];

	[self beginTouch: touch];

    if(holdTimeInSeconds != 0.0f)
        AppeckerWait(holdTimeInSeconds);


    [self endTouch: touch];

    [touch release];
}

-(void) tapCenterFor:(NSTimeInterval) holdTimeInSeconds andMoveToDir:(CGPoint) direction in:(NSTimeInterval) moveTimeInSeconds
{
    CGPoint initialPos = [self atfGetCenter];

    [self tapAtPos:initialPos for:holdTimeInSeconds andMoveToDir:direction in:moveTimeInSeconds];
}

-(void) tapAtPos:(CGPoint) initialPos  for:(NSTimeInterval) holdTimeInSeconds andMoveToDir:(CGPoint) direction in:(NSTimeInterval) moveTimeInSeconds
{

    CGPoint finalPos;

    finalPos.x =  initialPos.x + direction.x;
    finalPos.y = initialPos.y + direction.y;

    UITouch *touch = [[UITouch alloc] initInView:self withPosition:initialPos];

    [self beginTouch: touch];
    AppeckerWait(holdTimeInSeconds);
    [self moveTouch:touch to:finalPos in:moveTimeInSeconds];
    [self endTouch: touch];

    [touch release];

}

-(void) touchAndMove:(NSArray*)points in:(float)timeInSeconds{

    int count = [points count];
    if(count > 1){
        CGPoint pos;
        [[points objectAtIndex:0] getValue:&pos];
        UITouch *touch = [[UITouch alloc] initInView:self withPosition:pos];
        [self beginTouch: touch];

        for(int i=1; i<count; ++i){
            [[points objectAtIndex:i] getValue:&pos];
            [self moveTouch:touch to:pos in:timeInSeconds/(count -1)];
        }
        [self endTouch: touch];

        [touch release];
    }

}

-(void) doubleTap
{
    CGPoint pos = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    [self doubleTapAt: pos];
}

-(void) doubleTapAt:(CGPoint) pos
{

    UITouch *touch = [[UITouch alloc] initInView:self withPosition:pos withTapCount:2 isFirstTouchForView:YES];
    [self beginTouch: touch];
    AppeckerWait(0.2f);
    [self endTouch: touch];

    [touch release];
}

-(void) multiTap
{
    CGPoint pos = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    [self multiTapAt: pos];
}

-(void) multiTapAt:(CGPoint) pos
{

    UITouch *touch1 = [[UITouch alloc] initInView:self withPosition:CGPointMake(pos.x - 1.0, pos.y - 1.0)];
    UITouch *touch2 = [[UITouch alloc] initInView:self withPosition:CGPointMake(pos.x + 1.0, pos.y + 1.0)];
    NSSet *touches = [[NSMutableSet alloc] initWithObjects:touch1, touch2, nil];
    [self beginTouches: touches];
    AppeckerWait(0.2f);
    [self endTouches: touches];
    [touch1 release];
    [touch2 release];
    [touches release];

}

-(void) multiTouchAndMoveTouch1From:(CGPoint)pos11 to:(CGPoint)pos12 touch2From:(CGPoint)pos21 to:(CGPoint)pos22
{
    UITouch *touch1 = [[UITouch alloc] initInView:self withPosition:pos11];
    UITouch *touch2 = [[UITouch alloc] initInView:self withPosition:pos21 withTapCount:1 isFirstTouchForView:NO];
    NSSet *touches = [[NSMutableSet alloc] initWithObjects:touch1, touch2, nil];
    [self beginTouches: touches];
    [self moveTouch1:touch1 to:pos12 touch2:touch2 to:pos22 in: 0.5];
    [self endTouches: touches];
    [touch1 release];
    [touch2 release];
    [touches release];
}

-(void) pinchAt:(CGPoint)pos scale:(float) scale
{
	const float OFFSET = 10.0f;
    CGPoint pos11 = CGPointMake(pos.x - OFFSET, pos.y - OFFSET);
    CGPoint pos12 = CGPointMake(pos.x - (scale + OFFSET), pos.y - (scale + OFFSET));
    CGPoint pos21 = CGPointMake(pos.x + OFFSET, pos.y + OFFSET);
    CGPoint pos22 = CGPointMake(pos.x + (scale + OFFSET), pos.y + (scale + OFFSET));
    [self multiTouchAndMoveTouch1From:pos12 to:pos11 touch2From:pos22 to:pos21];
}


-(void) spreadAt:(CGPoint)pos scale:(float) scale
{
	const float OFFSET = 10.0;
	CGPoint pos11 = CGPointMake(pos.x - (scale + OFFSET), pos.y - (scale + OFFSET));
	CGPoint pos12 = CGPointMake(pos.x - OFFSET, pos.y - OFFSET);
    CGPoint pos21 = CGPointMake(pos.x + (scale + OFFSET), pos.y + (scale + OFFSET));
    CGPoint pos22 = CGPointMake(pos.x + OFFSET, pos.y + OFFSET);

    [self multiTouchAndMoveTouch1From:pos12 to:pos11 touch2From:pos22 to:pos21];
}


-(CGPoint) getCenter
{
	CGPoint o = self.frame.origin;
	float w = self.frame.size.width;
	float h = self.frame.size.height;

	CGPoint c;
	c.x = (o.x + w) / 2.f;
	c.y = (o.y + h) / 2.f;

	return c;
}

-(void) pinchAtCenterWithScale:(float) scale
{
	CGPoint c = [self getCenter];

	[self pinchAt:c scale:scale];
}


-(void) spreadAtCenterWithScale:(float)scale
{
	CGPoint c = [self getCenter];
	[self spreadAt:c scale:scale];
}

-(void) click{
    [self tap];
}

-(void) clickDirect{
	[self tapDirect];
}
@end
