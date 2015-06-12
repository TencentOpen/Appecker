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

#import "AppeckerContextWrapper.h"
#import "math.h"
#import "ATToolkit.h"
#import "ATViewPrivate.h"

#define BYTES_PER_PIXEL 4
#define BITES_PER_COMPONENT 8

@implementation AppeckerContextWrapper

@synthesize context = m_context;
@synthesize rawData = m_rawData;
@synthesize buffLen = m_buffLen;

-(NSUInteger) bytesPerPixel
{
    return BYTES_PER_PIXEL;
}

-(id) initWithUIView:(UIView*) view
{
    if(self = [super init]){

        CGSize originalSize = view.bounds.size;

        originalSize = ATSizeFloor(originalSize); //Some view have floating point size, so we have to floor it

        m_size = originalSize;

        //Be careful here, some views are ultra large, if you don't clamp, memory will be exhausted!
        m_size = ATClamp(m_size, ATGetScrSize());



        m_colorSpace = CGColorSpaceCreateDeviceRGB();

        m_buffLen = m_size.width * m_size.height * BYTES_PER_PIXEL;
        m_rawData = (unsigned char *) malloc(m_buffLen);


        memset(m_rawData, 0, m_buffLen);

        NSUInteger bytesPerRow = BYTES_PER_PIXEL * m_size.width;

        m_context = CGBitmapContextCreate(m_rawData, m_size.width, m_size.height, BITES_PER_COMPONENT, bytesPerRow, m_colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

#ifdef APPECKER_TRACE
        if(m_context == nil){
            [NSException raise:@"CGBitmapContextCreate" format:@"m_context is nil!"];
        }
#endif

        //fix coordinate difference, or the image will be upside-down
        CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, -1, 0, m_size.height);

        //if the view is too large, Appecker just render it in screen size
        if(!CGSizeEqualToSize(m_size, originalSize)){
            UIWindow* win;

            if([self isKindOfClass:[UIWindow class]])
                win = (UIWindow*) view;
            else
                win = [view atfWindow];

            CGRect rect = [win convertRect:view.bounds fromView:view];

            CGFloat offsetX;
            CGFloat offsetY;

            offsetX = rect.origin.x;
            offsetY = rect.origin.y;

            CGAffineTransform amend = CGAffineTransformMakeTranslation(offsetX, offsetY);
            transform = CGAffineTransformConcat(amend, transform);
        }

        CGContextConcatCTM(m_context, transform);



    }

    return self;

}

-(BOOL) isTransparent
{
    BOOL res = YES;
    for(int i = 0; i < m_buffLen; i+=self.bytesPerPixel){
        int alpha = m_rawData[i + self.bytesPerPixel - 1];
        if(alpha){
            res = NO;
            break;
        }
    }

    return res;
}

-(void) dealloc
{
    CGContextRelease(m_context), m_context = nil;

    free(m_rawData), m_rawData = nil;

    [super dealloc];
}

@end
