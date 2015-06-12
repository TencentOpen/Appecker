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

#import "ATDispatcher.h"

@implementation ATDispatcher

+(id) dispatcherWithTarget:(id)target{
    return [[[ATDispatcher alloc] initWithTarget:target retainTarget: NO] autorelease];
}

-(id) initWithTarget:(id)aTarget{
    return [self initWithTarget:aTarget retainTarget:NO];
}

-(id) initWithTarget:(id)aTarget retainTarget:(BOOL)retainTarget{
    self = [super init];
    if(nil != self){
        _retainTarget = retainTarget;
        _target = aTarget;
        if(retainTarget){
            [_target retain];
        }
    }
    return self;
}

-(void) dealloc{
    if(_retainTarget){
        [_target release];
    }
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = nil;
    if([super respondsToSelector:aSelector]){
        signature = [super methodSignatureForSelector:aSelector];
    }
    else if(nil != _target && [_target respondsToSelector:aSelector]){
        signature = [_target methodSignatureForSelector:aSelector];
    }
    return signature;
}

- (void) invokeAndRetainResult:(NSInvocation *) anInvocation{
    [anInvocation invoke];
    id result = nil;
    [anInvocation getReturnValue:&result];

    //MUST NOT retain UIView and UIViewController objects and put them into test thread autorelease pool
    if(![result isKindOfClass:[UIView class]] && ![result isKindOfClass:[UIViewController class]]){
        [result retain];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    anInvocation.target = _target;
    const char * returnType = [[anInvocation methodSignature] methodReturnType];
    if (0 == strcmp(returnType, "@")){
        //return type is decoded "id"
        [self performSelectorOnMainThread:@selector(invokeAndRetainResult:) withObject:anInvocation waitUntilDone:true];
        id result = nil;
        [anInvocation getReturnValue:&result];

        if(![result isKindOfClass:[UIView class]] && ![result isKindOfClass:[UIViewController class]]){
            [result autorelease];
        }
    }
    else{
        [anInvocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:true];
    }
}
@end

@implementation NSObject(ATDispatching)

-(id) dispatcher{
    return [ATDispatcher dispatcherWithTarget:self];
}

@end
