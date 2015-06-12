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

#import "Appecker.h"
#import "ATCaseRunner.h"
#import "ATTestCase.h"
#import "ATView.h"
#import "AppeckerTraceManagerPrivate.h"
#import "ATToolkit.h"
#import "AppeckerContextWrapper.h"
#import "ATViewPrivate.h"

@implementation UIView (ATViewScrCap)


-(NSString*) getDefaultImagePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    return path;
}

-(NSString*) getImgFileName:(NSString*) tag
{
    if(tag == nil)
        tag = @"defaultTag";
    NSMutableString* fileName = [[[NSMutableString alloc] initWithString:@""] autorelease];
    [fileName appendString:tag];
    [fileName appendString:@".png"];
    return fileName;
}

-(NSString*) getTxtFileName:(NSString*) tag
{
    NSString* imgFileName =  [self getImgFileName:tag];
    return [NSString stringWithFormat:@"%@.txt", imgFileName];
}

-(BOOL) makeDirWhenNecessary:(NSString*) basePath dir:(NSString*) dirName
{
    if(dirName == nil)
        return NO;

    NSFileManager* fileMgr = [NSFileManager defaultManager];

    NSString* fullPath = [basePath stringByAppendingPathComponent:dirName];

    BOOL isDir;
    if([fileMgr fileExistsAtPath:fullPath isDirectory:&isDir]){
        if(isDir)
            return YES;
    }

    BOOL b = [fileMgr createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:nil];

    return b;
}

-(NSString*) saveImage:(NSString*) tag image:(UIImage*) image dir:(NSString*) dir
{
    NSString* fileName = [self getImgFileName:tag];

    NSString* fullPath = [self getFullPathForFileName:fileName dir:dir];

    NSData* data = UIImagePNGRepresentation(image);

    [data writeToFile:fullPath atomically:YES];

    return fullPath;
}

-(NSString*) getFullPathForFileName:(NSString*) fileName dir:(NSString*) dir
{
    NSString* folderPath = [self getDefaultImagePath];
    NSString* fullPath = [folderPath stringByAppendingPathComponent:fileName];

    if([self makeDirWhenNecessary:folderPath dir:dir]){
        fullPath = [folderPath stringByAppendingPathComponent:dir];
        fullPath = [fullPath stringByAppendingPathComponent:fileName];
    }

    return fullPath;
}


-(NSString*) savePrintTree:(NSString*) tag dir:(NSString*) dir
{
    NSString* fileName = [self getTxtFileName:tag];

    NSString* fullPath = [self getFullPathForFileName:fileName dir:dir];

    NSString* tree;

    if([self isKindOfClass:[UIWindow class]])
        tree = [self getTree];
    else
        tree = [[self atfWindow] getTree];

    NSString* className = NSStringFromClass([self class]);

    NSString* viewDesc = [NSString stringWithFormat:@"%@:0x%x", className, self];

    NSString* final = [NSString stringWithFormat:@"%@\n%@", viewDesc, tree];

    NSData* data = [final dataUsingEncoding:NSUTF8StringEncoding];

    [data writeToFile:fullPath atomically:YES];

    return fullPath;

}

-(NSString*) captureView:(NSString*) tag dir:(NSString*) dir
{

    UIImage* image = [self getUIImage];
    [[AppeckerTraceManager sharedInstance] incTotalScrCapCounter];


    NSString* path = [self saveImage:tag image:image dir:dir];

    return path;
}

-(NSString*) captureView:(NSString*) tag
{
    NSString* path = [self captureView:tag dir:nil];

    return path;

}

-(UIImage*) getUIImage
{
    AppeckerContextWrapper* contextWrapper = [[AppeckerContextWrapper alloc] initWithUIView:self];

    [self.layer renderInContext:contextWrapper.context];

    CGImageRef cgImg = CGBitmapContextCreateImage(contextWrapper.context);

    [contextWrapper release];

    UIImage* viewImage = [UIImage imageWithCGImage:cgImg];

    return viewImage;
}

@end
