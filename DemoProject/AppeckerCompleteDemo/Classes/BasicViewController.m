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

#import "BasicViewController.h"


@implementation BasicViewController
@synthesize picker;

-(void) viewDidLoad{
	m_pickerData = [[NSArray alloc] initWithObjects:@"UIAutomation", @"UISpec", @"KIF", @"FoneMonkey", @"Appecker", nil];
	[super viewDidLoad];
}

-(void) viewDidUnload
{
	self.picker = nil;
	[m_pickerData release];
	[super viewDidUnload];
}

-(void) dealloc
{
	self.picker = nil;
	[m_pickerData release];
	[super dealloc];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [m_pickerData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [m_pickerData objectAtIndex:row];
}

@end
