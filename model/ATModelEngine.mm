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

#import "ATModelEngine.h"
#import "ATModel.h"
#import "ATAction.h"
#import "ATException.h"
#import "ATLogger.h"

@interface ATModelEngine (ATModelEnginePrivate)

-(ATAction *) pickActionFrom:(NSArray *)actions withTotalWeight:(int)totalWeight;
-(ATAction *) pickAction;
-(void) willPickAction;

@end


@implementation ATModelEngine
@synthesize maxSteps;
@synthesize steps;
@synthesize timeOut;
@synthesize random;

+(ATModelEngine*) modelEngineWithSeed:(unsigned)seed
{
    return [[[self alloc] initWithSeed:seed] autorelease];

}

+(void) runModel:(ATModelOuter *)model withSeed:(unsigned)seed
{
    ATModelEngine * engine = [ATModelEngine modelEngineWithSeed :seed];
    [engine navigateToNewModel:model];
    [engine run];
}


-(id) initWithSeed:(unsigned) seed{
    self = [super init];
    if(self != nil){
        random = [[ATRandom alloc] initWithSeed:seed];
        defaultStack = [[NSMutableArray alloc] init];
        currentStack = defaultStack;
        stacks = [[NSMutableDictionary alloc] init];
        maxSteps = 100;
        timeOut = 30 *60; //half an hour
        self->_actionInterval = 0;
    }
    return self;
}

-(void) dealloc{
    [defaultStack release];
    [stacks release];
    [random release];
    [super dealloc];
}


-(ATModelOuter *)topModel
{
    return [currentStack lastObject];
}

-(ATAction *) pickActionFrom:(NSArray *)actions withTotalWeight:(int)totalWeight{
    if(totalWeight > 0) {
        int index = [random getNextBetween:0 andBetween:totalWeight];
        int weight = 0;
        for(ATAction * action in actions){
            weight += action.weightWithModelFactor;
            if(weight > index){
                return action;
            }
        }
        ATLogError(@"You should never be here.");
    }

    return nil;
}

-(ATAction *) pickAction{
    [self willPickAction];
    NSArray *actions = [[self topModel] actions];
    NSMutableArray *executableActions = [NSMutableArray arrayWithCapacity:[actions count]];
    int totalWeight = 0;

    for(ATAction * action in actions){
        if(action.enabled && action.canExec && action.weightWithModelFactor > 0){
            [executableActions addObject:action];
            totalWeight += action.weightWithModelFactor;
        };
    }

    return [self pickActionFrom: executableActions withTotalWeight:totalWeight];
}

-(void)run{
    ATLogMessageFormat(@"Model engine started. Seed = %d", random.seed);

    NSDate *startTime = [NSDate date];
    NSAutoreleasePool *autoreleasePool = nil;
    @try{
        for(steps = 0; steps < maxSteps; ++steps){
            [autoreleasePool release];
            autoreleasePool = [[NSAutoreleasePool alloc] init];
            NSTimeInterval interval = [startTime timeIntervalSinceNow];
            if(interval > timeOut){
                ATLogMessage(@"Model timed out.");
                break;
            }

            ATAction * action = [self pickAction];
            if(nil == action){
                ATLogMessage(@"No executable actions available.");
                break;
            }

            [NSThread sleepForTimeInterval:0.5];
            [action exec];
            if(0 != self->_actionInterval)
            {
                [NSThread sleepForTimeInterval:self->_actionInterval];
            }
        }
        ATLogMessageFormat(@"Model exiting, %d steps execuated.", steps);
    }
    @catch (ATException *ex) {
        ATLogError([ex description]);
    }
    @catch (NSObject *ex) {
        ATLogErrorFormat(@"Model aborted due to exception: %@", ex);
    }
    @finally {
        // ensure the pool is released
        [autoreleasePool release];
    }
}

-(void) switchToNewModel:(ATModelOuter *)model
{
    ATLogMessageFormat(@"Switch to model: %@", NSStringFromClass([model class]));
    [currentStack removeLastObject];
    model.engine = self;
    [currentStack addObject:model];
    [model verify];
}

-(void) navigateToNewModel:(ATModelOuter *)model
{
    ATLogMessageFormat(@"Navigate to model: %@", NSStringFromClass([model class]));
    model.engine = self;
    [currentStack addObject:model];
    [model verify];
}

-(ATModelOuter *) navigateBack
{
    ATLogMessage(@"Navigate back");
    ATModelOuter * topModel = [[[currentStack lastObject] retain] autorelease];
    [currentStack removeLastObject];
    [[self topModel] reActive:topModel];
    return topModel;
}

-(void) switchToStack:(id) key
{
    currentStack = [stacks objectForKey:key];
    if(nil == currentStack){
        currentStack = [NSMutableArray array];
        [stacks setObject:currentStack forKey:key];
    }
    ATModelOuter *topModel = [self topModel];
    if(nil != topModel){
        [topModel reActive:nil];
    }
}

- (void)cleanStacks
{
    [self->stacks removeAllObjects];
    [self->defaultStack removeAllObjects];
    self->currentStack = self->defaultStack;
}

- (void)cleanCurrentStack
{
    if([self->currentStack count] <= 1)
    {
        return;
    }

    NSRange range = { 1, [currentStack count] - 1};
    [self->currentStack removeObjectsInRange:range];
}

-(void) setKeyForDefaultStack:(id)key
{
    [stacks setObject:defaultStack forKey:key];
}

-(void)setActionInterval:(NSTimeInterval)timeInterval
{
    self->_actionInterval = timeInterval;
}

-(void) willPickAction
{

}

@end
