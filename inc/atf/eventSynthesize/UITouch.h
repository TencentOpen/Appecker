//  Created by Eric Firestone on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#ifdef __IPHONE_6_1
@interface UITouch() {
    NSTimeInterval _timestamp;
    UITouchPhase _phase;
    UITouchPhase _savedPhase;
    NSUInteger _tapCount;

    UIWindow *_window;
    UIView *_view;
    UIView *_gestureView;
    UIView *_warpedIntoView;
    NSMutableArray *_gestureRecognizers;
    NSMutableArray *_forwardingRecord;

    CGPoint _locationInWindow;
    CGPoint _previousLocationInWindow;
    UInt8 _pathIndex;
    UInt8 _pathIdentity;
    float _pathMajorRadius;
    struct {
        unsigned int _firstTouchForView:1;
        unsigned int _isTap:1;
        unsigned int _isDelayed:1;
        unsigned int _sentTouchesEnded:1;
        unsigned int _abandonForwardingRecord:1;
    } _touchFlags;

}

@end
#endif