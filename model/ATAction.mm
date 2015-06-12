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

#import "ATAction.h"
#import "ATLogger.h"
#import "ATModel.h"

@implementation ATAction

@synthesize target = _target;
@synthesize selector = _selector;
@synthesize weight = _weight;
@synthesize canExecSelector = _canExecSelector;
@synthesize enabled = _enabled;

-(NSString *)name{
    NSString *name = nil;
    if(nil != _selector){
        name = NSStringFromSelector(_selector);
    }
    return name;
}

-(int) weightWithModelFactor{
    ATModelBase * model =  self.target;
    float fWeight = self.weight * model.factor;
    return ceilf(fWeight);
}

-(void) setCanExecSelector:(SEL) canExecSelector{
    _canExecSelector = canExecSelector;
    if(nil != _canExecInvocation){
        [_canExecInvocation release];
        _canExecInvocation = nil;
    }
}

+(ATAction *) actionWithTarget:(id)target selector:(SEL)selector canExecSelector:(SEL)canExecSelector weight:(int)weight{
    return [[[ATAction alloc] initWithTarget:target selector:selector canExecSelector:canExecSelector weight:weight] autorelease];
}


-(id)initWithTarget:(id)target selector:(SEL)selector canExecSelector:(SEL)canExecSelector weight:(int)weight{
    self = [super init];
    if(self != nil){
        self.target = target;
        self.selector = selector;
        self.weight = weight;
        self.canExecSelector = canExecSelector;
        self.enabled = YES;
    }
    return self;
}

-(void) dealloc{
    [_canExecInvocation release];
    [super dealloc];
}

-(void)exec{

    if([_target isKindOfClass:[ATModelInner class]])
    {
        ATLogMessageFormat(@"Entering call before %@:%s...", [_target class], sel_getName(_selector));
        [[(ATModelInner *)_target outerModel] willExecuteInnerModelAction:_target action:self];
        ATLogMessageFormat(@"Exited call before %@:%s", [_target class], sel_getName(_selector));
    }


    ATLogMessageFormat(@"==>Entering %@:%@...", NSStringFromClass([_target class]), NSStringFromSelector(_selector));
    [_target performSelector:_selector];
    ATLogMessageFormat(@"Exited %@:%@ =>", NSStringFromClass([_target class]), NSStringFromSelector(_selector));

    if([_target isKindOfClass:[ATModelInner class]])
    {
        [[(ATModelInner *)_target outerModel] didExecuteInnerModelAction:_target action:self];
    }
}

-(NSInvocation *) getCanExecInvocation{
    if(nil == _canExecInvocation && nil != _canExecSelector){
        NSMethodSignature * sig = [_target methodSignatureForSelector:_canExecSelector];
        _canExecInvocation = [NSInvocation invocationWithMethodSignature:sig];
        _canExecInvocation.selector = _canExecSelector;
        [_canExecInvocation retain];
    }
    return _canExecInvocation;
}

-(BOOL)canExec{
    BOOL canExec = YES;
    NSInvocation *canExecInvocation = [self getCanExecInvocation];
    if(nil != canExecInvocation){
        [canExecInvocation invokeWithTarget:self.target];
        [canExecInvocation getReturnValue:&canExec];
    }
    return canExec;
}
@end
