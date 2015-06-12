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

#import "MoveScaleImageView.h"

@implementation MoveScaleImageView

-(id) initWithImage:(UIImage*) image_a
{
	self = [super initWithImage:image_a];

	if(!self) return nil;

	self.userInteractionEnabled = YES;

	UIPinchGestureRecognizer* gr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];

	[self addGestureRecognizer:gr];

	[gr release];

	return self;
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];

		CGPoint anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        [piece.layer setAnchorPoint:anchorPoint];
        piece.center = locationInSuperview;
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
	if(gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateChanged)
		return;
	[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
	UIPinchGestureRecognizer* gr = (UIPinchGestureRecognizer*) gestureRecognizer;
	NSLog(@"Pinch detected:%f", [gr scale]);
	CGAffineTransform trans = gestureRecognizer.view.transform;
	CGFloat scale = gr.scale;
	gr.view.transform = CGAffineTransformScale(trans, scale, scale);
	gr.scale = 1;
}


@end