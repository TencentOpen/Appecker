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

#import "ATMacroRecSwitch.h"
#import "ATWindow.h"
#import <QuartzCore/QuartzCore.h>

#define RATIO_OF_WIDTH 0.15f

static ATMacroRecSwitch* s_instance = nil;

@implementation ATMacroRecSwitch

+(CGRect) MyFrame
{
    CGRect scrBounds = [[UIScreen mainScreen] bounds];
    CGFloat length = RATIO_OF_WIDTH * scrBounds.size.width;

    return CGRectMake(0, 0, length, length);
}

+(ATMacroRecSwitch*) sharedInstance
{
    if(!s_instance)
        s_instance = [[ATMacroRecSwitch alloc] initWithFrame:[self MyFrame]];

    return s_instance;
}

-(id) initWithFrame:(CGRect)frame
{
    if (s_instance) {
        [NSException raise:@"Singleton!" format:@"You are initilizing a singleton!"];
    }

    if(self = [super initWithFrame:frame]){
        m_doubleTapSelector = nil;
        m_doubleTapTarget = nil;

        m_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGes:)];
        m_tapRecognizer.numberOfTapsRequired = 2;

        [self addGestureRecognizer:m_tapRecognizer];

        self.windowLevel = [UIWindow GetHighestWindowLevel];
        self.alpha = 0.5f;
        self.layer.cornerRadius = 15.0f;
        self.backgroundColor = [UIColor grayColor];
    }

    return self;
}


-(void) dealloc
{
    [m_tapRecognizer release];
    [super dealloc];
}

-(void) setDoubleTapAction:(SEL) selector target:(id) target
{
    m_doubleTapSelector = selector;
    m_doubleTapTarget = target;
}

-(void) onTapGes:(UITapGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded)
        return;

    if(!m_doubleTapSelector)
        return;

    if(!m_doubleTapTarget)
        return;

    [m_doubleTapTarget performSelector:m_doubleTapSelector withObject:nil];

}

-(void) show
{
    [self makeKeyAndVisible];
    self.hidden = NO;
}

-(void) hide
{
    self.hidden = YES;
}

#pragma mark --Touch Related Begin---

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];

    m_oldPos = [touch locationInView:self];

    [super touchesBegan:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];

    [self updatePos:touch];

    [super touchesMoved:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_oldPos = CGPointMake(0.0f, 0.0f);

    [super touchesEnded:touches withEvent:event];

    [self magnetiz];
}

-(void) magnetiz
{
    CGFloat top, bottom, left, right;
    CGFloat x,y,width,height,scrWidth,scrHeight;

    CGRect scrBounds;

    scrBounds = [[UIScreen mainScreen] bounds];

    scrWidth = scrBounds.size.width;
    scrHeight = scrBounds.size.height;

    x = self.frame.origin.x;
    y = self.frame.origin.y;
    width = self.frame.size.width;
    height = self.frame.size.height;

    top = y;
    bottom =  scrHeight - ( y + height );
    left = x;
    right =  scrWidth - ( x + width );

    CGFloat min1 = fminf(top, bottom);
    CGFloat min2 = fminf(left, right);
    CGFloat min = fminf(min1, min2);

    CGRect newFrame = self.frame;;

    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4f];
    if(min == top){
        newFrame.origin.y = 0.0f;
    }else if(min == bottom)
    {
        newFrame.origin.y = scrHeight - height;
    }else if(min == left)
    {
        newFrame.origin.x = 0.0f;
    }else if(min == right)
    {
        newFrame.origin.x = scrWidth - width;
    }
    self.frame = newFrame;
    [UIView commitAnimations];


}


-(void) updatePos:(UITouch*) touch
{
    CGPoint pos = [touch locationInView:self];

    CGPoint origin = self.frame.origin;

    CGPoint newOrigin;
    newOrigin.x = origin.x + pos.x - m_oldPos.x ;
    newOrigin.y = origin.y + pos.y - m_oldPos.y;

    CGRect newFrame = self.frame;
    newFrame.origin = newOrigin;

    self.frame = newFrame;
}

#pragma mark --Touch Related End---


@end
