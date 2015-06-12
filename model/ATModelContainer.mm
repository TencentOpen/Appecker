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

#import "ATModel.h"

@implementation ATModelContainer

-(void)dealloc{
    [innerModels release];
    [super dealloc];
}

-(NSArray *) actions{

    if(nil == actions){
        NSArray *reisteredActions = [self registerActions];
        actions = [[NSMutableArray alloc] initWithArray:reisteredActions];
        for(ATModelInner *innerModel in innerModels)
        {
            NSArray *innerActions = [innerModel actions];
            [actions addObjectsFromArray:innerActions];
        }
    }
    return actions;
}

-(void) addInnerModel:(ATModelInner *) innerModel{
    if(nil == innerModels){
        innerModels = [[NSMutableArray alloc] initWithCapacity:2];
    }
    [innerModels addObject:innerModel];
    innerModel.outerModel = self;

    if(nil != actions){
        [actions release];
        actions = nil;
    }
}

-(void) removeAllInnerModels{
    if(nil != innerModels){
        int len = [innerModels count];
        for(int i = 0; i<len; ++i){
				ATModelInner *innerModel = [innerModels objectAtIndex:i];
				innerModel.outerModel = nil;
        }

		[innerModels removeAllObjects];
		if(nil != actions){
			[actions release];
			actions = nil;
		}
    }
}

-(void) removeInnerModel:(ATModelInner *) innerModel{
    if(nil != innerModels){
        int len = [innerModels count];
        for(int i = 0; i<len; ++i){
            if([innerModels objectAtIndex:i] == innerModel){
                [innerModels removeObjectAtIndex:i];
                innerModel.outerModel = nil;
                if(nil != actions){
                    [actions release];
                    actions = nil;
                }
                break;
            }
        }
    }
}


-(void)willExecuteInnerModelAction:(ATModelInner *)innerModel action:(ATAction *)anAction
{
    //override this function to do call before behavior
}


-(void)didExecuteInnerModelAction:(ATModelInner *)innerModel action:(ATAction *)anAction
{
    //override this function to do call after behavior
}

@end
