//
//  VisibleTouch.m
//  myMusicStand
//
//  Created by Steve Solomon on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

//This is just a small widget to show touch point, thanks to Steve Solomon!
#import "VisibleTouch.h"


#define BORDER 3 // border size what we draw

@implementation VisibleTouch

- (id)initWithFrame:(CGRect)frame
{
    @throw @"Illegal instance please use initWithCenter method instead";
}

- (id)init
{
    @throw @"Illegal instance please use initWithCenter method instead";
}

- (id)initWithTouch:(UITouch*) touch
{
    self = [super initWithFrame:CGRectMake(0, 0, 27, 27)];

    if (self)
    {
        m_touch = touch;  //Do NOT retain this object, or circular reference will occure!
        [self setBackgroundColor:[UIColor clearColor]];
    }

    return self;
}

- (id)show
{
    [m_touch.view addSubview:self];
    [self updatePosition];
}

- (id)disappear
{
    [self removeFromSuperview];
}

- (id)updatePosition
{
    CGPoint center = [m_touch locationInView:m_touch.view];
    [self setCenter:center];
    [m_touch.view bringSubviewToFront:self];
    [m_touch.view setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Clear our dirty rect
    CGContextClearRect(context, rect);

    // Shadow for circle
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(2, 2), 5, [[UIColor blackColor] CGColor]);

    // Draw circle
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    // draw circle with border on all sides
    rect.origin.x += 3;
    rect.origin.y += 3;
    rect.size.width -= 6;
    rect.size.height -= 6;
    CGContextFillEllipseInRect(context, rect);

    CGContextRestoreGState(context);
}


@end
