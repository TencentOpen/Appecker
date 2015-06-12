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

#import "MyTestCases.h"



@implementation MyTestCases

-(void) basic
{
	ATLogMessage(@"演示基本控件操作");
	AppeckerWait(3.0f);

	//[[UIWindow mainWindow] printTree];
    NSArray* windows =[UIWindow getallWindow];

	UITextField* txtField = [[UIWindow mainWindow] LocateViewByClass:[UITextField class]];
	UISwitch* switcher = [[UIWindow mainWindow] LocateViewByClass:[UISwitch class]];
	UISlider* slider = [[UIWindow mainWindow] LocateViewByClass:[UISlider class]];
	UIButton* btn = [[UIWindow mainWindow] LocateViewByClass:[UIButton class]];
	UIPickerView* picker = [[UIWindow mainWindow] LocateViewByClass:[UIPickerView class]];
	UISegmentedControl* segment = [[UIWindow mainWindow] LocateViewByClass:[UISegmentedControl class]];

	[txtField input:@"Appecker Demo!"];
	AppeckerWait(1.0f);
	[[txtField dispatcher] resignFirstResponder];
	AppeckerWait(1.0f);

	BOOL state = switcher.on;
	[switcher setStatus:!state];
	AppeckerWait(2.0f);


	[btn click];
	AppeckerWait(2.0f);

	[slider atfSetValue:0.1];
	AppeckerWait(1.0f);
	[slider atfSetValue:0.5];
	AppeckerWait(1.0f);
	[slider atfSetValue:0.99];
	AppeckerWait(1.0f);

	UILabel* secondLabel = [segment LocateViewByAttributeName:@"text" attrValKeyword:@"Second"];
	[secondLabel click];
	AppeckerWait(2.0f);

	[picker selectRow:4 inComponent:0];
	AppeckerWait(2.0f);
}

-(void) goBack
{
    AppeckerWait(2.0f);
	UINavigationBar* navBar = [[UIWindow mainWindow] LocateViewByClass:[UINavigationBar class]];
	[navBar clickLeftBtn];
    AppeckerWait(2.0f);
}

-(void) pinch
{
	ATLogMessage(@"演示手势支持");
    AppeckerWait(2.0f);

	NSArray* ary = [[UIWindow mainWindow] LocateViewsByClass:[UIImageView class]];
	UIImageView* imgView = [[UIWindow mainWindow] LocateViewByClass:[UIImageView class]];

	[imgView pinchAtCenterWithScale:10.f];
	ATLogMessage(@"Pinch finished!");
    AppeckerWait(1.0f);
	[imgView spreadAtCenterWithScale:20.f];
	ATLogMessage(@"Spread finished!");
    AppeckerWait(1.0f);
}

-(void) wipe
{
	ATLogMessage(@"演示滑动操作");
    AppeckerWait(2.0f);

	UIScrollView* scrollView = [[UIWindow mainWindow] LocateViewByClass:[UIScrollView class]];

	CGPoint pos1,pos2;

	pos1.x = 160;
	pos1.y = 100;

	pos2.x = 160;
	pos2.y = 280;

	[scrollView touchAndMoveFrom:pos2 to:pos1 in:3];

    AppeckerWait(2.0f);

}

-(void) web
{
	ATLogMessage(@"演示webview支持");
    AppeckerWait(20.0f);
	UIWebView* webView = [[UIWindow mainWindow] LocateViewByClass:[UIWebView class]];

	[webView printDOMTree];

	NSUInteger inputNum = [webView getNodeWithTagNum:@"input"];

	for(int i = 0; i < inputNum; i++){
		ATLogMessage([webView getNodeWithTagDesc:@"input" idx:i]);
	}

    [webView setInputValue:@"1575000142" idx:5];
    AppeckerWait(2.0f);

	[webView setInputValue:@"qq2010" idx:6];
    AppeckerWait(2.0f);

	[webView setInputChecked:NO idx:7];
    AppeckerWait(2.0f);

	[webView clickNodeWithTag:@"input" idx:8];
    AppeckerWait(5.0f);

	CGPoint pos1,pos2;
	pos1.x = 160;
	pos1.y = 100;

	pos2.x = 160;
	pos2.y = 260;

	UIScrollView* scrollView = [webView LocateViewByClass:[UIScrollView class]];

	[scrollView touchAndMoveFrom:pos2 to:pos1 in:3];

    AppeckerWait(2.0f);

	[webView clickNodeWithValue:@"退出"];

    AppeckerWait(7.0f);
}

-(BOOL) isCellValid:(NSMutableDictionary*) localMem
{
	UITableViewCell* cell = [localMem objectForKey:@"cell"];
	NSArray* ary = [cell LocateViewsByClass:[UILabel class]];

	if(![ary count])
		return NO;

	return YES;
}

-(void) dealWithCell:(NSMutableDictionary*) localMem
{
	UITableViewCell* cell = [localMem objectForKey:@"cell"];
	UILabel* label = [cell LocateViewByClass:[UILabel class]];
	NSString* text = [label text];

	if([text isEqualToString:@"BasicDemo"]){
		[cell click];
		[self basic];
		[self goBack];
	}
     else if([text isEqualToString:@"PinchDemo"]){
		[cell click];
		[self pinch];
		[self goBack];
	}
     else if([text isEqualToString:@"WipeDemo"]){
		[cell click];
		[self wipe];
		[self goBack];
	}
        else if([text isEqualToString:@"WebDemo"]){
		[cell click];
		[self web];
		[self goBack];
	}
}

-(void) testcase_allInOne
{
	AppeckerWait(4.0f);

    [AppeckerTraceManager sharedInstance].traceMode =YES;

	UITableView* tableView = [[UIWindow mainWindow] LocateViewByClass:[UITableView class]];

    ATLogMessage(@"准备截图");
    NSString* path = [tableView captureView:@"tableView" dir:@"testCap"];
    ATLogMessage(@"截图完毕！");
    ATLogMessageFormat(@"存储至: %@", path);

	NSMutableDictionary* localMem = [[NSMutableDictionary alloc] init];
	[tableView iterateWithObject:self predicate:@selector(isCellValid:) method:@selector(dealWithCell:) localMem:localMem];
	[localMem release];

	ATLogMessage(@"演示完毕，谢谢观看！");
}

@end
