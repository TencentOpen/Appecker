//  Created by Eric Firestone on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>


@interface KIFEventProxy : NSObject
{
@public
	unsigned int flags;
	unsigned int type;
	unsigned int ignored1;
	float x1;
	float y1;
	float x2;
	float y2;
	unsigned int ignored2[10];
	unsigned int ignored3[7];
	float sizeX;
	float sizeY;
	float x3;
	float y3;
	unsigned int ignored4[3];
}

@end

@implementation KIFEventProxy
@end


@interface UIView (EventFactory)

- (UIEvent *)_eventWithTouch:(UITouch *)touch;

@end

@implementation UIView (EventFactory)

- (UIEvent *)_eventWithTouches:(NSSet *)touches
{
	return (UIEvent *)[self  _eventWithTouchesInternal:touches];
}

- (UIEvent *)_eventWithTouch:(UITouch *)touch
{
	NSSet* touches = [NSSet setWithObjects:touch, nil];

	return (UIEvent *)[self _eventWithTouchesInternal:touches];
}

- (UIEvent *)_eventWithTouchesInternal:(NSSet *)touches;
{
    UIEvent *event = [[UIApplication sharedApplication] performSelector:@selector(_touchesEvent)];

	UITouch *touch = [touches anyObject];

    CGPoint location = [touch locationInView:touch.window];
    KIFEventProxy *eventProxy = [[KIFEventProxy alloc] init];
    eventProxy->x1 = location.x;
    eventProxy->y1 = location.y;
    eventProxy->x2 = location.x;
    eventProxy->y2 = location.y;
    eventProxy->x3 = location.x;
    eventProxy->y3 = location.y;
    eventProxy->sizeX = 1.0;
    eventProxy->sizeY = 1.0;
    eventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    eventProxy->type = 3001;


    NSSet *allTouches = [event allTouches];
    [event _clearTouches];
    [allTouches makeObjectsPerformSelector:@selector(autorelease)];
    [event _setGSEvent:(struct __GSEvent *)eventProxy];

	for(UITouch* touch in touches){
		[event _addTouch:touch forDelayedDelivery:NO];
	}

    [eventProxy release];
    return event;
}

@end


