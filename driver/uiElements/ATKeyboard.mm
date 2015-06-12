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

#import "ATView.h"
#import "ATKeyboard.h"

/* keyboard tree
UITextEffectsWindow
    UIKeyboard
        UIKeyboardImpl
            UIKeyboardLayoutQWERTY
                UIKeyboardSublayout
                    UIImageView
                    UIKeyboardSpaceKeyView
                    UIKeyboardReturnKeyView
*/

@implementation ATKeyboard
+(BOOL) isAvailable{
    return nil != [self keyboard];
}
+(UIWindow*) keyboard{
    UIWindow * keyboard = nil;

    NSArray *wArray = [[UIApplication sharedApplication] windows];
    for(int i=0; i< [wArray count]; i++)
    {
        UIWindow *window = [wArray objectAtIndex:i];
        if([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]){
            if([window LocateViewByClassName:@"UIPeripheralHostView"] && [window LocateViewByClassName:@"UIKeyboardCornerView"]){
                keyboard = window;
                break;
            }
        }
    }

    return keyboard;
}


+(void) resignAllResponderInner:(UIView*) rootView
{
    if(rootView.isFirstResponder)
        [rootView resignFirstResponder];

    for(UIView* view in rootView.subviews){
        [self resignAllResponderInner:view];
    }
}

+(void) closeKeyboard
{
    UIWindow* keyWin = [[UIApplication sharedApplication] keyWindow];


    [self resignAllResponderInner:keyWin];
}


//These methods are obsoleted in iOS5.0
//+(void) clickReturnKey{
//
//    UIView * keyboard = [self keyboard];
//    UIView * returnKey = [keyboard LocateViewByClassName:@"UIKeyboardReturnKeyView"];
//    [returnKey click];
//
//}
//
//+(void) clickSpaceKey{
//    UIView * keyboard = [self keyboard];
//    UIView * spaceKey = [keyboard LocateViewByClassName:@"UIKeyboardSpaceKeyView"];
//    [spaceKey click];
//
//}
@end
