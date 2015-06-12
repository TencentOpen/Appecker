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

#import "ATTextAlertView.h"
#import "ATWindow.h"

@interface ATTextAlertView(Private)
@end

@implementation MyTextView
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(copy:))
        return YES;
    return NO;
}
@end

@implementation ATTextAlertView

-(id) initWithTitle:(NSString*) title message:(NSString*) message
{
    CGRect scrBounds = [[UIScreen mainScreen] bounds];

    if(self = [self initWithFrame:scrBounds]){

        CGFloat titleWidth,titleHeight;
        titleWidth = scrBounds.size.width;
        titleHeight = 20;
        m_title = [[UIButton alloc] init];
        m_title.frame = CGRectMake(0, 0, titleWidth, titleHeight);
        m_title.backgroundColor = [UIColor whiteColor];
        [m_title setTitle:title forState:UIControlStateNormal];
        [m_title setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

        [m_title addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDownRepeat];
        [self addSubview:m_title];


        CGFloat textWidth,textHeight;
        textWidth = scrBounds.size.width;
        textHeight = scrBounds.size.height - titleHeight;
        m_text = [[MyTextView alloc] init];
        m_text.text = message;
        m_text.frame =  CGRectMake(0, titleHeight, textWidth, textHeight);
        m_text.delegate = self;
        m_text.inputView = [[UIView alloc] initWithFrame:CGRectZero];
        [m_text select:self];
        NSRange range;
        range.location = 0;
        range.length = [message length];
        [m_text setSelectedRange:range];

        [self addSubview:m_text];
        [m_text becomeFirstResponder];

        m_dismissAction = nil;
        m_dismissTarget = nil;

        return self;
    }

    return nil;

}

-(void) setDismissAction:(SEL) selector withTarget:(id) target
{
    m_dismissAction = selector;
    m_dismissTarget = target;
}

-(void) show
{
    m_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    m_window.windowLevel = [UIWindow GetHighestWindowLevel];

    [m_window addSubview:self];

    [m_window makeKeyAndVisible];
}

-(void) performDismissAction
{
    if(!m_dismissAction)
        return;

    if(!m_dismissTarget)
        return;

    [m_dismissTarget performSelector:m_dismissAction withObject:nil];
}

-(void) dismiss
{
    [self performDismissAction];

    [self removeFromSuperview];
    [m_window release];
}

-(void) dealloc
{
    [m_text.inputView release];
    [m_text release];
    [m_title release];
}

#pragma mark --------UITextViewDelegate--------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return NO;
}
#pragma mark --------UITextViewDelegate--------


@end
