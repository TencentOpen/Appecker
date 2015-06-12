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
#import <objc/runtime.h>
#import "ATLauncher.h"
#import "ATLogger.h"

@interface Appecker : NSObject
{
    BOOL m_macroRecMode;
    BOOL m_start;
    BOOL m_background;
}

+(Appecker*) sharedInstance;
-(void) turnOff;
-(BOOL) isInMacroRecMode;
-(void) enableMacroRecMode;

@end
