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
#import "ATAction.h"

@class ATModelEngine;
@class ATModelOuter;


@interface ATModelBase : NSObject{
    NSMutableArray *actions;
    float factor;
}

@property (nonatomic) float factor;
@property (nonatomic, assign, readonly) ATModelEngine * engine;

-(NSArray *) actions;
-(NSArray *) registerActions;

@end


@interface ATModelOuter : ATModelBase{
    ATModelEngine * engine;
    NSArray *stack;
}

@property(nonatomic, assign) ATModelEngine * engine;
@property(nonatomic, assign) NSArray * stack;

-(void)reActive:(ATModelOuter *)currentModel;
-(void)verify;

@end

@class ATModelInner;

@interface ATModelContainer : ATModelOuter{
    NSMutableArray *innerModels;
}
-(void)addInnerModel:(ATModelInner *) innerModel;
-(void)removeInnerModel:(ATModelInner *) innerModel;
-(void)removeAllInnerModels;
-(void)willExecuteInnerModelAction:(ATModelInner *)innerModel action:(ATAction *)anAction;
-(void)didExecuteInnerModelAction:(ATModelInner *)innerModel action:(ATAction *)anAction;
@end


@interface ATModelInner : ATModelBase{
    ATModelContainer *outerModel;
}

@property(nonatomic, assign) ATModelContainer * outerModel;
-(void)reActive;
@end