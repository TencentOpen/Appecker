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
#import "ATTextView.h"
#import "ATWaitUtility.h"

@interface UITextView(PrivateAtfMethods)
-(void) simulateReturnInternal;
@end


@implementation UITextView (ATTextView)

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
    [self becomeFirstResponder];
    AppeckerWait(0.3);
    [self setText:text];
    AppeckerWait(0.3);
    [self resignFirstResponder];
}

-(void)inputCharacters:(NSString *)text
{

    [self becomeFirstResponder];
    AppeckerWait(1.0f);
    [self setText:text];
    AppeckerWait(0.3f);
}

-(void)setCharacter:(NSMutableDictionary *) objectDictionary
{
    NSRange range;
    range.length = 0;
    range.location = [[objectDictionary objectForKey:@"RangeLocation"] intValue];
    NSString * text = [objectDictionary objectForKey:@"Text"];
    [[self delegate] textView:self shouldChangeTextInRange:range replacementText:text] ;
}

-(void)commitPSMUpdate
{
    int currentLength = [self.text length];
    NSMutableDictionary * objectDictionary = [[NSMutableDictionary alloc] init];
    [objectDictionary setObject:[NSString stringWithFormat:@"%d",currentLength] forKey:@"RangeLocation"];
    [objectDictionary setObject:@"\n" forKey:@"Text"];
    [self setCharacter:objectDictionary];
    AppeckerWait(0.5f);
    [objectDictionary release];
}

-(void)commitUpdateByNL
{
    NSMutableDictionary * objectDictionary = [[NSMutableDictionary alloc] init];
    [objectDictionary setObject:@"\n" forKey:@"Text"];
    [self setCharacter:objectDictionary];
    AppeckerWait(0.5f);
    [objectDictionary release];
}


-(void)simulateReturn
{
    id<UITextViewDelegate>  delegate = [self delegate];
    if([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
        NSRange range;
        range.length = 0;
        range.location = [self.text length];
        [delegate textView:self shouldChangeTextInRange:range replacementText:@"\n"] ;
    }
    if([delegate respondsToSelector:@selector(textViewDidEndEditing:)]){
        [delegate textViewDidEndEditing:self];
    }
}
@end
