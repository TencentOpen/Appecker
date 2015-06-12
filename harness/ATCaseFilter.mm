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

#import "ATCaseFilter.h"


@implementation ATCaseFilter

-(id) initWithCaseFilter:(NSString *) caseFilter classFilter:(NSString *) classFilter
{
    self = [super init];
    if(nil != self){
        _caseFilter = nil;
        if([caseFilter length] > 0){
            _caseFilter = [[NSString alloc] initWithFormat:@".%@_", caseFilter];
        }

        _classFilters = nil;
        if([classFilter length] > 0){
            NSArray *classFilters = [classFilter componentsSeparatedByString:@"|"];
            _classFilters = [classFilters retain];
        }
    }
    return self;
}

-(void) dealloc
{
    [_caseFilter release];
    [_classFilters release];
    [super dealloc];
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"{case: %@; class: %@", _caseFilter, [_classFilters componentsJoinedByString:@"|"]];
}

-(BOOL) isClassMatches:(NSString *) className
{
    BOOL matches = YES;
    if(nil != _classFilters){
        matches = NO;
        for(NSString * aFilter in _classFilters){
            if([className hasPrefix:aFilter]){
                matches = YES;
                break;
            }
        }
    }
    return matches;
}

-(BOOL) isCaseMatches:(NSString *) caseName
{
    BOOL matches = YES;
    if(nil != _caseFilter){
        NSRange range = [caseName rangeOfString:_caseFilter options:NSCaseInsensitiveSearch];
        if( NSNotFound == range.location){
            matches = NO;
        }
    }
    return matches;
}

@end
