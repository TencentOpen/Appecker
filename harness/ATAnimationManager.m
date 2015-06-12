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

#import "ATAnimationManager.h"


@implementation ATAnimationManager

Appecker_DEFINE_SINGLETON(ATAnimationManager);

-(id) init
{
    if(self = [super init])
    {
    m_animationCounter = 0;
#ifdef APPECKER_TRACE

        m_animationSet = [[NSMutableSet alloc] init];
#endif
    }

    return self;
}

-(BOOL) isAnimationOK:(CAAnimation*) theAnimation
{

    if([theAnimation respondsToSelector:@selector(repeatCount)])
    {
        float repeatCnt = [theAnimation repeatCount];
        if(repeatCnt > 1000.0f)
            return NO;
    }

    return YES;
}

-(void) onAnimationStart:(CAAnimation*) theAnimation
{
    if(![self isAnimationOK:theAnimation])
        return;

#ifdef APPECKER_TRACE
    [m_animationSet addObject:theAnimation];
#endif

    m_animationCounter ++;
}

-(void) onAnimationStop:(CAAnimation*) theAnimation finished:(BOOL) flag
{
    if(![self isAnimationOK:theAnimation])
        return;

#ifdef APPECKER_TRACE
    [m_animationSet removeObject:theAnimation];
    ATSay(@"0x%x", [m_animationSet anyObject]);
#endif

    m_animationCounter --;
}

-(BOOL) isAllAnimationFinished
{
#ifdef APPECKER_TRACE
    ATSay(@"animation counter: %d", m_animationCounter);
#endif
    return m_animationCounter == 0;
}

@end
