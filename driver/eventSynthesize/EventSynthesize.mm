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

#import "EventSynthesize.h"

@implementation UIEventInternal

@end

@interface UITouchesEventInternal()
- (void) printTouches;
- (void) printTimestamp;
- (void) printKeyedTouchesDictionary;
- (void) printGSEvent;
- (void) dump;
@end

@implementation UITouchesEventInternal

- (id)initWithTouch:(UITouch *)touch
{
    NSSet * touches = [[[NSMutableSet alloc] initWithObjects:&touch count:1] autorelease];
    [self initWithTouches:touches];
    return self;
}

- (id)initWithTouches:(NSSet *)touches
{
    self = [super init];
    if (self != nil)
    {
        self->_touches = [touches retain];
        self->_timestamp = [NSDate timeIntervalSinceReferenceDate];

        NSArray *allTouches = [touches allObjects];
        UITouch *touch1 = [allTouches objectAtIndex:0];
        UITouch *touch2 = touch1;
        if([allTouches count] >= 2){
            touch2 = [allTouches objectAtIndex:1];
        }

        //TODO: determine the defination for _event, and initialize it completely
        CGPoint location = [touch1 locationInView:touch1.window];
        CGPoint location2 = [touch2 locationInView:touch2.window];
        self->_gsEvent = [[GSEventProxy alloc] init];
        self->_gsEvent->x = (location.x + location2.x)/2.0f;
        self->_gsEvent->y = (location.y + location2.y)/2.0f;
        self->_gsEvent->x2 = location.x;
        self->_gsEvent->y2 = location.y;

        CFMutableDictionaryRef dict = CFDictionaryCreateMutable(
                                                                kCFAllocatorDefault,
                                                                0,
                                                                &kCFTypeDictionaryKeyCallBacks,
                                                                &kCFTypeDictionaryValueCallBacks);

        CFDictionaryAddValue(dict, touch1.view, self->_touches);
        CFDictionaryAddValue(dict, touch1.window, self->_touches);

        self->_keyedTouches = dict;
    }
    self->isa = NSClassFromString(@"UITouchesEvent");
    return self;
}


- (void)printTouches{
    printf("Touches\n");
    for(UITouch *touch in self->_touches){
        printf("%s\n", [[touch description] UTF8String]);
    }
}

- (void) printTimestamp{
    printf("TimeStamp:%5.3f\n", self->_timestamp);
}

- (void) printKeyedTouchesDictionary{

}

- (void) printGSEvent{
    GSEventProxy * e = (GSEventProxy *) self->_gsEvent;
    printf("GSEvent\n");
    printf("x= %f, y= %f\n", e->x, e->y);
    printf("ignored1:");
    for(int i = 0; i < 5; ++i){
        printf("%08X,", e->ignored1[i]);
    }
    printf("\n");

    printf ("ignored2:");
    for(int i = 0; i< 24; ++i){
        printf("%08X ", e->ignored2[i]);
    }

    printf("\n%f, %f, %f", *(float*)(e->ignored2 + 11),*(float*)(e->ignored2 + 12), *(float*)(e->ignored2 + 13));
    printf("\n%f, %f", *(float*)(e->ignored2 + 18), *(float*)(e->ignored2 + 19));


}

- (void) dump
{
    printf("\n");
    [self printTimestamp];
    [self printTouches];
    //[self printKeyedTouchesDictionary];
    //[self printGSEvent];
}
@end
