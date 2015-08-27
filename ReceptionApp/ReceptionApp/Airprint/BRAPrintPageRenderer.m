/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "BRAPrintPageRenderer.h"

@implementation BRAPrintPageRenderer

- (void)drawPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)printableRect {
    CGSize imageSize = self.image.size;
    CGRect newRect = [self aspectFitRectFrom:printableRect forImageSize:imageSize];
    [self.image drawInRect:newRect];
}

- (CGRect)aspectFitRectFrom:(CGRect)printableRect forImageSize:(CGSize)imageSize {
    CGSize viewSize = printableRect.size; // size in which you want to draw

    CGFloat hfactor = imageSize.width / viewSize.width;
    CGFloat vfactor = imageSize.height / viewSize.height;

    CGFloat factor = MAX(hfactor, vfactor);

    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    CGFloat newWidth = imageSize.width / factor;
    CGFloat newHeight = imageSize.height / factor;

    CGFloat xOffset = CGRectGetMidX(printableRect) - newWidth / 2;
    CGFloat yOffset = CGRectGetMidY(printableRect) - newHeight / 2;
    CGRect newRect = CGRectMake(xOffset, yOffset, newWidth, newHeight);
    return newRect;
}

@end