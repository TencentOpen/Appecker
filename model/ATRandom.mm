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

#import "ATRandom.h"
#include <stdlib.h>

@implementation ATRandom

@synthesize seed = _seed;

-(void)setSeed:(unsigned)seed{
    _seed = seed;
    nextSeed = seed;
}

-(id) initWithSeed:(unsigned)seed{
    self = [super init];
    if(self != nil){
        _seed = seed;
        nextSeed = seed;
    }
    return self;
}

-(int) getNext{
    srandom(nextSeed);
    int rndValue = random();
    nextSeed = (unsigned) rndValue / 2;
    return rndValue;
}

-(int) getNextBetween:(int)min andBetween:(int)max{
    if(min == max)
    {
        return min;
    }

    int rndValue = [self getNext];
    return rndValue % (max - min) + min;
}

-(int) getNextInteger:(int)boundary
{
    if(boundary <= 0) return 0;
    int rndValue = [self getNext];
    return rndValue % boundary;
}

+(int) randomBetween:(int)min Max:(int)max Seed:(unsigned)seed;
{
    ATRandom *random = [[ATRandom alloc] initWithSeed:seed];
    int result = [random getNextBetween:min andBetween:max];
    [random release];
    return result;
}

@end
