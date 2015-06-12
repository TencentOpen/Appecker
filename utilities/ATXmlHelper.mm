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

#import "ATXmlHelper.h"

@implementation ATXmlHelper

+(NSString *)filterInvalidChar:(NSString *) data
{
    //InvalidChar ::= [#x0-#x8] | #xB | #xC | [#xE - #x1F] | [#xD800 - #xDFFF] | #xFFFE | #xFFFF
    NSString* pattern = @"[\\u0000-\\u0008\\u000B\\u000C\\u000E-\\u001F\\uD800-\\uDFFF\\uFFFE\\uFFFF]";
    NSString* defaultStr = @"?";

    NSError* error;

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSRange range = {0, data.length};

    NSString* cleanData = [regex stringByReplacingMatchesInString:data options:NSRegularExpressionCaseInsensitive range:range withTemplate:defaultStr];

    return cleanData;

}

+(NSString *) escape:(NSString *)data{

    if(!data)
    {
        return nil;
    }

    NSMutableString *output = nil;
    int startPos = 0;
    int len = [data length];
    for (int i = 0; i < len; ++i)
    {
        NSString * replacement = nil;
        unichar ch = [data characterAtIndex:i];
        switch (ch) {
            case '<':
                replacement = @"&lt;";
                break;
            case '>':
                replacement = @"&gt;";
                break;
            case '&':
                replacement = @"&amp;";
                break;
            case '"':
                replacement = @"&quot;";
                break;
            case '\'':
                replacement = @"&apos;";
                break;
            default:
                break;
        }
        if(replacement != nil){
            if(nil == output){
                output = [NSMutableString stringWithCapacity:len * 1.3];
            }
            if(i > startPos){
                [output appendString:[data substringWithRange: NSMakeRange(startPos, i - startPos)]];
            }
            [output appendString:replacement];
            startPos = i + 1;
        }
    }
    if(output == nil){
        return data;
    }
    else if(startPos < len){
        [output appendString:[data substringWithRange: NSMakeRange(startPos, len - startPos )]];
    }
    return output;
}
@end



