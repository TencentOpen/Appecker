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

#import "RootController.h"
#import "BasicViewController.h"
#import "PinchViewController.h"
#import	"WipeViewController.h"
#import "WebViewController.h"

static NSString* s_basic = @"BasicDemo";
static NSString* s_pinch = @"PinchDemo";
static NSString* s_wipe = @"WipeDemo";
static NSString* s_web = @"WebDemo";



@implementation RootController

-(void) viewDidLoad
{
	self.title = @"Atf Demo";
	m_controllers = [[NSMutableArray alloc] init];
	m_listData = [[NSArray alloc] initWithObjects:s_basic, s_pinch, s_wipe, s_web, nil];

	BasicViewController* basicController = [[BasicViewController alloc] initWithNibName:@"Basic" bundle:nil];
	[m_controllers addObject:basicController];

	PinchViewController* pinchController = [[PinchViewController alloc] init];
	[m_controllers addObject:pinchController];

	WipeViewController* wipeController = [[WipeViewController alloc] initWithNibName:@"Wipe" bundle:nil];
	[m_controllers addObject:wipeController];

	WebViewController* webController = [[WebViewController alloc] initWithNibName:@"Web" bundle:nil];
	[m_controllers addObject:webController];

	[super viewDidLoad];
}

-(void) viewDidUnload
{
	[m_controllers release];
	[m_listData release];
	[super viewDidUnload];
}

-(void) dealloc
{
	[m_listData release];
	[m_controllers removeAllObjects];
	[m_controllers release];
	[super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
	NSString* key = @"simpleKey";
	int row = [indexPath row];

	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:key];
	if(!cell)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key] autorelease];

	cell.textLabel.text = [m_listData objectAtIndex:row];

	return cell;
}


-(NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section{
	return [m_listData count];
}

-(void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath
{
	NSUInteger row = [indexPath row];

	[self.navigationController pushViewController:[m_controllers objectAtIndex:row] animated:YES];

}
#pragma mark -

@end
