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

#import "BRASignoutCollectionCell.h"

@interface BRASignoutCollectionCell ()

@property (nonatomic, strong) UIImageView *cellImageView;

@end

@implementation BRASignoutCollectionCell

#pragma mark - Class methods

+ (UIColor *)backgroundColor {
    return [UIColor colorWithWhite:0.95 alpha:1.0];
}

#pragma mark - private

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetWidth(self.frame)/2;
    self.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [[self class] backgroundColor];
}

- (void)setupCellImageView {
    self.cellImageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    self.cellImageView.image = self.cellImage;
    self.cellImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.cellImageView.layer.masksToBounds = YES;
    self.cellImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.cellImageView];
}


#pragma mark - Setter

- (void)setCellImage:(UIImage *)cellImage {
    if (![_cellImage isEqual:cellImage]) {
        _cellImage = cellImage;
        [self setupCellImageView];
    }
}

@end
