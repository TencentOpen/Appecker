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
#import "ATFramework.h"
#import "AppeckerContextWrapper.h"
#import "ATViewPrivate.h"

@implementation UIView ( ATViewDebug )

-(BOOL) isParentViewOf:(UIView*) sub;
{
	BOOL found= NO;

    NSArray* subViewAry = [self subviews];

	for (UIView* view in subViewAry) {
		if([view isEqual:sub])
			found = YES;



		else
			found = [view isParentViewOf:sub];

		if(found) return YES;
	}

	return NO;
}


-(BOOL) isChildViewOf:(UIView*) parentView
{
    UIView* superView = [self superview];

    if(superView == parentView)
        return YES;

    BOOL b = [superView isChildViewOf:parentView];

    if(b)
        return YES;

    return NO;
}


-(CGRect) getViewFrameInAncestorView:(UIView*) view
{
#ifdef APPECKER_TRACE
    //some view has an independent window, which doesn't contains it in subviews!
    if (view && view != self && ![view isParentViewOf:self]) {
        NSString* selfName = NSStringFromClass([self class]);
        NSString* viewName = NSStringFromClass([view class]);

        ATSay(@"0x%x(%@) is not superview of 0x%x(%@)", view, viewName, self, selfName);
        ATSay(@"0x%x(%@).window = 0x%x", self, selfName, self.window);
    }
#endif

    CGRect rect;

    rect.origin = CGPointMake(0.0f, 0.0f);

    rect.size = self.bounds.size;
    //Notice:
    //We must use covertRect to convert the original frame to destination frame, or we will lose some information about affine transform. The result is
    //that if we call printTree on a transformed view, it will definitely yield wrong frame of the transformed view and all its subviews.
    rect = [self convertRect:rect toView:view];

    return rect;
}


-(NSString*) tryToPerformSelector:(SEL) selector
{
    NSString* res = @"";
    try {
        @try {
            res = [self performSelector:selector];
        }
        @catch (NSException *exception) {
#ifdef APPECKER_TRACE
            ATSay(@"Obj-C exception when perform selector:%@", NSStringFromSelector(selector));
            ATSay(@"name:%@", [exception name]);
            ATSay(@"reason: %@", [exception reason]);
            ATSay(@"0x%x(%@)", self, NSStringFromClass([self class]));
#endif
        }
        @finally {

        }
    }catch (...) {
#ifdef APPECKER_TRACE
        ATSay(@"C++ exception when perform selector:%@", NSStringFromSelector(selector));
        ATSay(@"0x%x(%@)", self, NSStringFromClass([self class]));
#endif
    }

    return res;
}

-(NSString *) getTreeWithDepth:(int) depth
{
    //print indent spaces
    NSMutableString *tempString = [NSMutableString string];
    for(int i = 0; i <depth; ++ i){
        [tempString appendString:@"  "];
    }

    [tempString appendFormat:@"%@ (0x%x)", NSStringFromClass([self class]), self];

    int tag = [self tag];
    if(tag > 0){
        [tempString appendFormat:@" {tag = %d}", [self tag]];
    }

    NSString * title = nil;
    NSString * attrName = nil;

    attrName = @"currentTitle";
    SEL sel = NSSelectorFromString(attrName);
    if([self respondsToSelector:sel]){
        title = [self tryToPerformSelector:sel];
    }

    if(![title respondsToSelector:@selector(length)] || [title length] == 0){
        attrName = @"title";
        sel = NSSelectorFromString(attrName);
        if([self respondsToSelector:sel]){
            title = [self tryToPerformSelector:sel];
        }
    }
    if(![title respondsToSelector:@selector(length)] || [title length] == 0){
        attrName = @"text";
        sel = NSSelectorFromString(attrName);
        if([self respondsToSelector:sel]){
            title = [self tryToPerformSelector:sel];
        }
    }

    // TODO: (Dong) automation hook for what's new logging, use category or add the hook into dev code
    //if([title length] == 0 && [self class] == [WLRichTextView class]){
//        attrName = @"text";
//        WLRichText *richText = ((WLRichTextView *)self).richText;
//        title = richText->GetText();
//    }

    if([title respondsToSelector:@selector(length)] && [title length] > 0){
        [tempString appendFormat:@" {%@ = %@}", attrName, title];
    }

    CGRect finalFrame;

    if([self isKindOfClass:[UIWindow class]])
        finalFrame = [self getViewFrameInAncestorView:nil];
    else
        finalFrame = [self getViewFrameInAncestorView:[self atfWindow]];

    [tempString appendFormat:@" {frame = %d, %d, %d, %d}", (int)finalFrame.origin.x, (int)finalFrame.origin.y, (int)finalFrame.size.width, (int)finalFrame.size.height];

    UIResponder *nextResponder = [self nextResponder];
    if([nextResponder isKindOfClass:[UIViewController class]]){
        [tempString appendFormat:@" <== %@", NSStringFromClass([nextResponder class])];
    }

    [tempString appendString:@"\n"];

    for(UIView* subView in [self subviews])
    {
        [tempString appendString:[subView getTreeWithDepth:(depth + 1)]];
    }
    return tempString;
}

-(NSString *) getTreeInternal
{
    return [self getTreeWithDepth:0];
}

-(UIWindow*) atfWindow
{
    UIView* view = self;

    while (view.superview != nil) {
        view = view.superview;
    }

    if(![view isKindOfClass:[UIWindow class]]){
        ATSay(@"No window of view(0x%x,%@) found!", view, NSStringFromClass([view class]));
        return nil;
    }

    return (UIWindow*)view;
}

-(void) printTree2
{
    NSString *outputString  = [self getTreeInternal];
    ATLogMessageFormat(@"%@",outputString);
}

-(void) printTree
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSString *outputString  = [self  getTreeInternal];
    ATLogMessageFormat(@"%@",outputString);
    [pool release];
}

-(UIViewController*) findControllerInSingleView:(UIView*) view controllClass:(Class) controllerClass
{
	UIResponder* responder;

	responder = [view nextResponder];

	while(![responder isKindOfClass:controllerClass] && responder){
		responder = [responder nextResponder];
	}

	return (UIViewController*)responder;
}

-(void) flattenViewTreeToArray:(NSMutableArray*) subViewsArray
{
	//Please be sure to init subViewsArray properly before passing it to this function,
	//or memory corruption will surely happen!!

	[subViewsArray addObject:self];

	for(UIView* subView in self.subviews){
		[subView flattenViewTreeToArray:subViewsArray];
	}
}

-(UIViewController*) findControllerWithNameInternal:(NSString*) controllerClassName
{
	Class controllerClass = NSClassFromString(controllerClassName);

	NSMutableArray* allViews = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];

	[self flattenViewTreeToArray:allViews];

	UIViewController* controller;
	for(UIView* view in allViews){
		controller = [view findControllerInSingleView:view controllClass:controllerClass];
		if(controller)
			return controller;
	}

	return nil;
}

-(void) printResponderChainInternal
{
	UIResponder* responder;
	int i;

	for(i = 0, responder = [self nextResponder]; responder; responder = [responder nextResponder], i++ ){
		ATLogMessageFormat(@"Responder:%d [%@:0x%x]", i, NSStringFromClass([responder class]), responder);
	}
}

-(UIViewController*) findControllerWithName:(NSString*) controllerClassName
{
	return [self findControllerWithNameInternal:controllerClassName];
}

-(void) printResponderChain
{
	[self printResponderChainInternal];
}

-(NSString *) getTree
{
    return [self getTreeInternal];
}

-(void) printSuperViewChainInternal
{
	UIView* view;
	int i = 0;


	for(UIView* view = self; view != nil; view = view.superview, i ++){
		ATLogMessageFormat(@"View:%d [%@:0x%x]",i , NSStringFromClass([view class]), view);
	}
}

-(CGPoint) atfGetCenter
{
    //Get center point in local coordinate system
    CGPoint centerPos;

    centerPos.x = self.frame.size.width / 2;
    centerPos.y = self.frame.size.height / 2;

    return centerPos;
}

-(void) printSuperViewChain
{
	[self printSuperViewChainInternal];
}

//for gdb debug only
-(void) printFrameOnScr
{
    CGRect rect;
    rect = self.bounds;

    rect = [self convertRect:rect toView:self.window];
    ATSay(@"frame: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

-(BOOL) containsPos:(CGPoint) pos
{
    return CGRectContainsPoint(self.frame, pos);
}


@end
