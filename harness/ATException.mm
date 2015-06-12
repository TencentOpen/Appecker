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

#import "ATException.h"
#import <execinfo.h>

@implementation ATException
@synthesize callStack;
@synthesize message;

+(id)exceptionWithMessage:(NSString *)msg{
    return [[[ATException alloc] initWithMessage:msg] autorelease];
}

-(id)initWithMessage:(NSString *)msg{
    self = [super init];
    if(self != nil){
        self.message = msg;
        callStack = [[NSMutableString alloc] initWithCapacity:1024];
        void* stack[128];
        int frames = backtrace(stack, 128);
        char** strs = backtrace_symbols(stack, frames);
        for (int i = 0; i < frames; ++i) {
            [callStack appendFormat:@"%s\n", strs[i]];
        }
        free(strs);
    }
    return self;
}

-(void)dealloc{
    [callStack release];
    [message release];
    [super dealloc];
}

-(NSString *) description{
    // TODO:
    return [NSString stringWithFormat:@"Message:  %@\n Call Ctack\n%@", message, callStack];
}
@end


@implementation ATValidationException
+(id)exceptionWithMessage:(NSString *)msg{
    return [[[ATValidationException alloc] initWithMessage:msg] autorelease];
}
@end
