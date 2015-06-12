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

#import "ATMPMoviePlayerController.h"
#import "ATUtilities.h"

@implementation MPMoviePlayerController (ATMPMoviePlayerController)

-(NSURL*) getContentURL
{
	NSURL* url = (NSURL*)[self contentURL];

	return url;
}

-(BOOL) isControlBarShowing
{
	UIView* overlayView = [[UIWindow mainWindow] LocateViewByClass:NSClassFromString(@"MPFullScreenVideoOverlay")];

	if(overlayView == nil){
		ATSay(@"Can't find MPFullScreenVideoOverlay!");
		return NO;
	}


	return !overlayView.hidden;
}


-(void) atfPause
{
	[self pause];
}

-(void) atfPlay
{
	[self play];
}

-(void) atfStop
{
	[self stop];
}

-(void) atfBeginSeekingBackward
{
	[self beginSeekingBackward];
}

-(void) atfBeginSeekingForward
{
	[self beginSeekingForward];
}

-(void) atfEndSeeking
{
	[self endSeeking];
}


-(UIView*) getOverlayView
{
	UIView* view = [[UIWindow mainWindow] LocateViewByClass:NSClassFromString(@"MPFullScreenVideoOverlay")];

	if(view == nil){
		ATSay(@"Can't find MPFullScreenVideoOverlay!");
		return nil;
	}

	return view;
}

-(void) showControlBar
{
	UIView* overlayView = [self getOverlayView];
	[overlayView click];

	int alpha = (int)[overlayView  alpha];
	while (!(alpha = (int)[overlayView alpha])) {
		AppeckerWait(0.05);
	}

}


-(void) clickForward
{
	UIView* overlayView = [self getOverlayView];
	UIView* nextBtn = [overlayView LocateViewByTag:4];

	[nextBtn clickDirect];
}

-(void) clickBack
{
	UIView* overlayView = [self getOverlayView];
	UIView* backBtn = [overlayView LocateViewByTag:2];


	[backBtn clickDirect];
}

-(void) clickMiddleBtn
{
	UIView* overlayView = [self getOverlayView];
	UIView* midBtn = [overlayView LocateViewByTag:1];

	[midBtn clickDirect];
}

-(void) clickPlay
{
	MPMoviePlaybackState state = self.playbackState;
	if(state != MPMoviePlaybackStatePaused)
		return;

	[self clickMiddleBtn];
}

-(void) clickPause
{
	MPMoviePlaybackState state = self.playbackState;
	if(state != MPMoviePlaybackStatePlaying)
		return;

	[self clickMiddleBtn];
}

-(UIView*) getNavBtnByIdx:(NSUInteger) idx
{
	NSArray* ary = [[UIWindow mainWindow] LocateViewsByClassName:@"UINavigationButton"];

	if([ary count] == 0){
		ATSay(@"Can't locate navigation button!");
		return nil;
	}

	return [ary objectAtIndex:idx];
}



-(void) clickDone
{
	UIView* doneBtn = [self getNavBtnByIdx:0];

	[doneBtn clickDirect];
}

-(void) clickZoomBtn
{
	UIView* fullScrBtn = [self getNavBtnByIdx:1];

	[fullScrBtn clickDirect];
}

-(void) setProgressInternal:(NSNumber*) percent
{
	NSUInteger totalTime = self.duration;

	NSTimeInterval time = int(totalTime * [percent doubleValue]);

	self.currentPlaybackTime = time;
}

-(void) setProgress:(NSUInteger) progress
{
	progress = progress > 100 ? 100 : progress;

	double percent = (double)progress / 100.0f;
	NSNumber* percentObj = [NSNumber numberWithDouble:percent];

	[self setProgressInternal:percentObj];
}
@end
