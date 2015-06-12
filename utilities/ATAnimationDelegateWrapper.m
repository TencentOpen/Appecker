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

#import "ATAnimationDelegateWrapper.h"
#import "ATAnimationManager.h"

@implementation ATAnimationDelegateWrapper

-(id) initWithDelegate:(id) delegate
{
    if(self = [super init])
    {
        m_delegate = [delegate retain];
    }

    return self;
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    [[ATAnimationManager sharedInstance] onAnimationStart:theAnimation];
    if([m_delegate respondsToSelector:@selector(animationDidStart:)])
    {
        [m_delegate animationDidStart:theAnimation];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [[ATAnimationManager sharedInstance] onAnimationStop:theAnimation finished:flag];
    if([m_delegate respondsToSelector:@selector(animationDidStop:finished:)])
    {
        [m_delegate animationDidStop:theAnimation finished:flag];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    anInvocation.target = m_delegate;
    [anInvocation invoke];
}

- (void) dealloc
{
    [m_delegate release], m_delegate = nil;
    [super dealloc];
}

@end
