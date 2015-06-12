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

#import "ATToolkit.h"

CGSize ATGetScrSize()
{
    return [UIScreen mainScreen].bounds.size;
}

CGSize ATClamp(CGSize original, CGSize limit)
{
    original.width = original.width > limit.width ? limit.width : original.width;
    original.height = original.height > limit.height ? limit.height : original.height;

    return original;
}

CGSize ATSizeFloor(CGSize size)
{
    size.width = floor(size.width);
    size.height = floor(size.height);

    return size;
}

NSUInteger ATFloor(CGFloat val)
{
    return (NSUInteger)floor(val);
}
