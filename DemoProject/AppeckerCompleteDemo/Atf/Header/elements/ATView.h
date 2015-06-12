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

#import <Foundation/Foundation.h>
#import "../locator/ATCondition.h"

@interface UIView (ATDispatching)

-(UIView *) dispatcher;
-(id) atfGetAttrVal:(NSString * )attrName;

@end


@interface UIView (ATViewLocator)

-(NSArray *) LocateViewsByCondition: (ATCondition *)condition;

-(id) LocateViewByCondition: (ATCondition *)condition;
-(id) LocateViewByClassName: (NSString *) className;
-(id) LocateViewsByClassName: (NSString *) className;
-(id) LocateViewByClass: (Class) type;
-(id) LocateViewsByClass: (Class) type;
-(id) LocateViewByExactClass: (Class) type;
-(id) LocateViewsByExactClass: (Class) type;
-(id) LocateViewByExactClassName: (NSString *) className;
-(id) LocateViewByTag:(NSInteger)tag;
-(id) LocateViewByAttributes:(NSDictionary *)attributesSet;
-(id) LocateViewByAttributeName:(NSString *)attributeName attributeValue:(NSString *)attributeValue;

-(id) LocateViewByCondition: (ATCondition *)condition occurAt:(int)times;
-(id) LocateViewByClassName: (NSString *) className occurAt:(int)times;
-(id) LocateViewByClass: (Class) type occurAt:(int)times;
-(id) LocateViewByAttributes:(NSDictionary *)attributesSet occurAt:(int)times;
-(id) LocateViewByAttributeName:(NSString *)attributeName attributeValue:(NSString *)attributeValue occurAt:(int)times;

-(id) LocateViewByExactFrame:(CGRect) frame;
-(id) LocateViewByFrame:(CGRect) frame bias:(NSUInteger) bias;
-(id) LocateViewByAttributeName:(NSString*) attrName attrValKeyword:(NSString *)keyword;
-(id) LocateViewsBySubViewDesc:(NSString*) subViewDesc;


@end

@interface UIView ( ATViewGestures )
-(void) tap;
-(void) tapAtMiddleUpper;
-(void) doubleTap;
-(void) doubleTapAt:(CGPoint) pos;
-(void) multiTap;
-(void) multiTapAt:(CGPoint) pos;
-(void) tapAt:(CGPoint) pos;
-(void) tapAtPositionByRatioX:(float)ratioX ratioY:(float)ratioY;
-(void) touchAndMoveFrom:(CGPoint) pos1 to:(CGPoint) pos2 in:(float)timeInSeconds;
-(void) touchAndMove:(NSArray*)points in:(float)timeInSeconds;

-(void) spreadAtCenterWithScale:(float)scale;
-(void) pinchAtCenterWithScale:(float) scale;
-(void) spreadAt:(CGPoint)pos scale:(float) scale;
-(void) pinchAt:(CGPoint)pos scale:(float) scale;

-(void) click;

@end


@interface UIView ( ATViewDebug )

-(void) printTree;
- (NSString *) getTree;
-(UIViewController*) findControllerWithName:(NSString*) name;
-(void) flattenViewTreeToArray:(NSMutableArray*) subViewsArray;
-(BOOL) isParentViewOf:(UIView*) sub;

-(void) printResponderChain;
-(void) printSuperViewChain;

@end

