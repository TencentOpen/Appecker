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
#import "ATTableView.h"
#import "ATButton.h"
#import "ATTableViewCell.h"
#import "ATWindow.h"
#import "ATViewQuery.h"
#import "ATWaitUtility.h"

@implementation UITableView (ATTableView)

-(UITableViewCell *)cellAtRowIndex:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    [self scrollToRowAtIndexPath:indexPath];
    return [(UITableView *)self cellForRowAtIndexPath:indexPath];
}


-(void)scrollToRowAtIndexPath:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    [(UITableView *)self
     scrollToRowAtIndexPath:indexPath
     atScrollPosition:UITableViewScrollPositionNone
     animated:YES];
    AppeckerWait(0.5);
}

-(void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(UITableView *)self
     scrollToRowAtIndexPath:indexPath
     atScrollPosition:UITableViewScrollPositionNone
     animated:YES];
    AppeckerWait(0.5);
}

-(void)scrollToTop
{
    [(UITableView *)self
     setContentOffset:CGPointMake(0,0)
     animated:YES];
    AppeckerWait(2.0f);
}

-(void)scrollToBottom
{

    CGFloat height = 9999; //self.frame.size.height;

    [(UITableView *)self
     setContentOffset:CGPointMake(0,height)
     animated:YES];
    AppeckerWait(1.0f);

	ATLogMessageFormat(@"%d sections", [self numberOfSections]);
    int numOfRows = [self numberOfRowsInSection:0];
	ATLogMessageFormat(@"%d rows in section 0", numOfRows);
    if(numOfRows >= 1)
	{
		[self scrollToRowAtIndexPath:numOfRows -1 inSection:0];
	}
    AppeckerWait(1.0f);
}


-(void)iterateWithObject:(id)target predicate:(SEL) predicate method:(SEL) method localMem:(NSMutableDictionary*) localMem
{
	if (![target respondsToSelector:predicate]
		|| (predicate != nil && ![target respondsToSelector:method])
		) {
		ATSay(@"Error: Target can't respond predicate or method! Please check!");
		return;
	}

	int sectionNum = (int)[self numberOfSections];

	BOOL goOn = YES;

	for(int section = 0; section < sectionNum; section++){
		if(!goOn) break;

		int rowNum = [self numberOfRowsInSection:section];

		for(int row = 0; row < rowNum; row ++){
			UITableViewCell* cell = [self cellAtRowIndex:row inSection:section];
			[localMem setObject:cell forKey:@"cell"];
			[localMem setObject:[NSNumber numberWithInt:section] forKey:@"section"];
			[localMem setObject:[NSNumber numberWithInt:row] forKey:@"row"];

			NSString* justGoOn = [localMem objectForKey:@"continue"];

			if(justGoOn != nil && [[justGoOn lowercaseString] isEqualToString:@"no"]){
				goOn = NO;
				break;
			}

			if(predicate != nil && ![target performSelector:predicate withObject:localMem])
				continue;

			[target performSelector:method withObject:localMem];
		}
	}
}

-(void)clickCellInRow:(int) row section:(int) section
{
	UITableViewCell* cell = [self cellAtRowIndex:row inSection:section];
	[cell click];
}

@end
