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

#import "ATScrollView.h"
#import "ATUtilities.h"
#import "ATViewPrivate.h"



@implementation UIScrollView ( ATScrollowView )

-(void) scrollsSubViewVisible:(UIView*) view
{
	if([view atfWindow] != [self atfWindow]){
		ATSay(@"Both view must be in the same window!");
		return;
	}

	CGRect viewFrame = [view.superview convertRect:view.frame toView:self];

	[(UIScrollView*)self scrollRectToVisible:viewFrame animated:YES];
    AppeckerWait(1.0f);
}

-(void) scrollToLeft
{
	CGPoint pos = (CGPoint)[self  contentOffset];
    [self scroll:CGPointMake(0, pos.y)];
}

-(void) scrollToRight
{
    CGFloat scrollerSize = self.contentSize.width;
    CGFloat offset = self.frame.size.width;
	CGPoint pos = [self contentOffset];

	[self scroll:CGPointMake(scrollerSize - offset, pos.y)];
}

-(void) scrollToTop {
	CGPoint pos = [self contentOffset];
    [self scroll:CGPointMake(pos.x, 0)];
}


-(void) scrollToBottom {
	UIScrollView *scroller = (UIScrollView *)self;
    CGFloat scrollerSize = scroller.contentSize.height;
    CGFloat offset = scroller.frame.size.height;
	CGPoint pos = [self contentOffset];

	[self scroll:CGPointMake(pos.x, scrollerSize - offset)];
}

-(void) scrollVertically:(int)offset{
	CGPoint pos = [self contentOffset];
    [self scroll:CGPointMake(pos.x,offset)];
}

-(void) scrollHorizontally:(int)offset{
	CGPoint pos = [self contentOffset];
    [self scroll:CGPointMake(offset, pos.y)];
}

-(void) scrollLeftRight:(BOOL) left
{
    CGFloat offset = self.frame.size.width;

	if(left)
		offset = -offset;

	CGPoint pos = [self contentOffset];
    [self scrollHorizontally:pos.x + offset];
}

-(void) scrollLeft
{
    [self scrollLeftRight:YES];
}

-(void) scrollRight
{
	[self scrollLeftRight:NO];
}

-(void) scrollUpDown:(BOOL) up
{
    CGFloat offset = self.frame.size.height;
	CGPoint pos = [self contentOffset];

	if(!up){
		offset = -offset;
	}

	[self scrollVertically:pos.y + offset];
}

-(void) scrollUp {
    [self scrollUpDown:YES];
}

-(void) scrollDown{
    [self scrollUpDown:NO];
}

-(void) scroll:(CGPoint)offsetPoint {
	[self setContentOffset:offsetPoint animated:YES];
}
@end
