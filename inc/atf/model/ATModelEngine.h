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
#import "ATRandom.h"

@class ATModelOuter;

@interface ATModelEngine : NSObject {
    int maxSteps;
    int steps;
    NSTimeInterval timeOut;
    ATRandom *random;
    NSMutableDictionary * stacks;
    NSMutableArray * defaultStack;
    NSMutableArray * currentStack;
    NSTimeInterval _actionInterval;
}

@property(nonatomic)int maxSteps;
@property(nonatomic, readonly) int steps;
@property(nonatomic)NSTimeInterval timeOut;
@property(nonatomic, readonly, retain) ATRandom * random;
@property(nonatomic, readonly, retain) ATModelOuter * topModel;

+(ATModelEngine*) modelEngineWithSeed:(unsigned)seed;
+(void) runModel:(ATModelOuter *)model withSeed:(unsigned)seed;

-(id) initWithSeed:(unsigned) seed;
-(void) run;

// swithch the current stack to the stack identified by the key
// create a new stack if the target stack is not available
-(void) switchToStack:(id) key;

// clean all stacks, default, current stack
- (void)cleanStacks;

- (void)cleanCurrentStack;

// bind the default stack to a given key
-(void) setKeyForDefaultStack:(id)key;

-(void) switchToNewModel:(ATModelOuter *)model;
-(void) navigateToNewModel:(ATModelOuter *)model;
-(ATModelOuter *) navigateBack;
-(void)setActionInterval:(NSTimeInterval)timeInterval;
//-(ATAction *) pickAction;

@end
