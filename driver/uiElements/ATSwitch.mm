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

#import "ATSwitch.h"
#import "ATUICommon.h"
#import "ATWaitUtility.h"


@implementation UISwitch (ATSwitch)

-(void)setStatus:(BOOL)on
{

    if(on)
    {
        [self setOn];
    }
    else
    {
        [self setOff];
    }
}

-(void)commitChange
{
    AppeckerWait(0.5);
    [self atfActivateEvent:UIControlEventValueChanged];
}

-(void)setOn
{
    [self setOn:YES animated:YES];
    [self commitChange];
}

-(void)setOff
{
    [self setOn:NO animated:YES];
    [self commitChange];
}

@end
