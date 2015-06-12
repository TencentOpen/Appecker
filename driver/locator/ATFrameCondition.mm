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

#import "ATFrameCondition.h"
#import "ATView.h"
#import "ATViewPrivate.h"

@implementation ATFrameCondition


-(id)initWithFrameRect:(CGRect)frame_a bias:(int) bias_a
{
	if( self = [ super init ] ){
		frame = frame_a;
		bias = bias_a;
	}
	return self;
}

-(BOOL) check:(UIView *)view
{
	CGRect rect = [view getViewFrameInAncestorView:[view atfWindow]];

	//NSLog(@"Checking: %d, %d, %d, %d", (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height);

	BOOL xOK = abs(rect.origin.x - (int)frame.origin.x) <= bias;
	BOOL yOK = abs((int)rect.origin.y - (int)frame.origin.y) <= bias;
	BOOL widthOK = abs((int)rect.size.width - (int)frame.size.width) <= bias;
	BOOL heightOK = abs((int)rect.size.height - (int)frame.size.height) <= bias;

	return 	xOK && yOK && widthOK && heightOK;
}


@end

