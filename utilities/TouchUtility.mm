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

#import <Foundation/Foundation.h>

void visualizeTouch(UITouch* touch)
{
    if(![touch isKindOfClass:[UITouch class]]){
        NSLog(@"Only UITouch is supported!");
        return;
    }

    [[UIWindow mainWindow] printTree];

    NSUInteger tapCount = [touch tapCount];
    UITouchPhase phase = [touch phase];
    UIView* view = [touch view];
    NSString* viewName = NSStringFromClass([view class]);
    NSString* phraseName = nil;

    switch (phase) {
        case UITouchPhaseBegan:
            phraseName = @"UITouchPhaseBegan";
            break;

        case UITouchPhaseMoved:
            phraseName = @"UITouchPhaseMoved";
            break;

        case UITouchPhaseCancelled:
            phraseName = @"UITouchPhaseCancelled";
            break;

        case UITouchPhaseStationary:
            phraseName = @"UITouchPhaseStationary";
            break;

        case UITouchPhaseEnded:
            phraseName = @"UITouchPhaseEnded";
            break;

        default:
            break;
    }

    NSLog(@"\n");
    NSLog(@"UITouch: 0x%x", touch);
    NSLog(@"tapCount: %u", tapCount);
    NSLog(@"view: 0x%x(%@)", view, viewName);
    NSLog(@"phrase: %@", phraseName);

}
