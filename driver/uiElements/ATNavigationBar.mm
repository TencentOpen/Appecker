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

#import "ATNavigationBar.h"
#import "ATLogger.h"

typedef enum{
    LEFT_BTN,
    RIGHT_BTN
} BTN_TYPE;


@implementation UINavigationBar (ATNavigationBar)

-(UIView*) getSpecifiedBtn:(BTN_TYPE) type
{
	NSArray* buttons = [self LocateViewsByClass:[UIButton class]];

	if([buttons count] == 0){
		buttons = [self LocateViewsByClass:NSClassFromString(@"UINavigationItemButtonView")];
	}

    if([buttons count] > 2){
        ATSay(@"Current navigation bar has more than 2 buttons, ignored!");
        return nil;
    }

    if([buttons count] == 1){
        if(type == LEFT_BTN)
            return [buttons objectAtIndex:0];
        else{
            ATSay(@"Only left button exists, ignored!");
            return nil;
        }
    }

    UIView* leftBtn;
    UIView* rightBtn;

    leftBtn = [buttons objectAtIndex:0];
    rightBtn = [buttons objectAtIndex:1];

    if(leftBtn.frame.origin.x  > rightBtn.frame.origin.x){
        UIView* tmp;
        tmp = leftBtn;
        leftBtn = rightBtn;
        rightBtn = tmp;
    }



	return type == LEFT_BTN ? leftBtn : rightBtn;
}

-(void) clickLeftBtn
{
    [[self getSpecifiedBtn:LEFT_BTN] click];
}

-(void) clickRightBtn
{
    [[self getSpecifiedBtn:RIGHT_BTN] click];
}

@end

