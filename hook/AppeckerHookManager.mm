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

#import "AppeckerHookManager.h"
#import <objc/runtime.h>

@implementation AppeckerHookManager

+ (void)hijackInstanceSelector:(SEL)originalSelector inClass:(Class) srcCls withSelector:(SEL)newSelector inClass:(Class) dstCls
{

    Method originalMethod = class_getInstanceMethod(srcCls, originalSelector);
    Method categoryMethod = class_getInstanceMethod(dstCls, newSelector);
    method_exchangeImplementations(originalMethod, categoryMethod);
}

+ (void)hijackClassSelector:(SEL)originalSelector inClass:(Class) srcCls withSelector:(SEL)newSelector inClass:(Class) dstCls
{

    Method originalMethod = class_getClassMethod(srcCls, originalSelector);
    Method categoryMethod = class_getClassMethod(dstCls, newSelector);
    method_exchangeImplementations(originalMethod, categoryMethod);
}


@end
