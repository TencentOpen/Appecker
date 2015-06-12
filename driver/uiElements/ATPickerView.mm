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

#import "ATPickerView.h"
#import "ATWaitUtility.h"


@implementation UIPickerView (ATPickerView)

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSMutableArray *package = [NSMutableArray arrayWithObjects:
                        [NSNumber numberWithInt:row], [NSNumber numberWithInt:component], nil];

    [self selectRow:package];
    AppeckerWait(0.5);
    [self commitChange:package];
}

-(void)selectRow:(NSArray*)package
{
    NSNumber *row = [package objectAtIndex:0];
    NSNumber *component = [package objectAtIndex:1];
    [self selectRow:[row intValue] inComponent:[component intValue] animated:YES];
}

-(void)commitChange:(NSArray*)package
{
    NSNumber *row = [package objectAtIndex:0];
    NSNumber *component = [package objectAtIndex:1];

	id pickerDelegate = [self delegate];

	if([pickerDelegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]){
		[[self delegate] pickerView:self didSelectRow:[row intValue] inComponent:[component intValue]];
	}
}

@end
