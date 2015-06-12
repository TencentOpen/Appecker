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
#import "ATTextField.h"
#import "ATUICommon.h"
#import "ATWaitUtility.h"

@interface UITextField (ATTextFieldPrivate)

-(void)commitChange;

@end


@implementation UITextField (ATTextField)

-(NSString *) atfText
{
    NSString * text = [self text];
    return text;
}

-(NSString *) atfPlaceHolder
{
    NSString * placeholder = [self placeholder];
    return placeholder;
}

-(void)input:(NSString *)text{
    [self tap];
    AppeckerWait(0.3);
    [self setText:text];
    AppeckerWait(0.3);

	[self notifyContentChange];
}

-(void) notifyContentChange
{
    [self atfActivateEvent:UIControlEventEditingChanged];
}

-(void)inputAndReturn:(NSString *)text
{
    [self input:text];
    AppeckerWait(1.0f);
    //[ATKeyboard clickReturnKey];
    [self commitChange];

}

-(void)commitChange
{
    id delegate = [self delegate];
    if([delegate respondsToSelector:@selector(textFieldShouldReturn:)]){
        [delegate textFieldShouldReturn:self];
    }

    [self atfActivateEvent:UIControlEventEditingDidEndOnExit];
}
@end
