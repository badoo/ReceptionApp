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

#import "BRASearchTableViewCell.h"

@implementation BRASearchTableViewCell

+ (CGFloat)imageMarginFraction {
    return 0.125f;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.layer.masksToBounds = YES;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat delta = CGRectGetHeight(self.contentView.bounds) * [[self class] imageMarginFraction];
    CGFloat sideWidth = CGRectGetHeight(self.contentView.bounds) - 2 * delta;

    self.imageView.frame = CGRectMake(2 * delta, delta, sideWidth, sideWidth);
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame)/2;

    CGRect labelFrame = self.textLabel.frame;
    labelFrame.origin.x = CGRectGetMaxX(self.imageView.frame) + 2 * delta;
    self.textLabel.frame = labelFrame;

    self.separatorInset = UIEdgeInsetsMake(0.0f, CGRectGetMinX(self.textLabel.frame), 0.0f, 0.0f);
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    self.textLabel.text = @"";
}

@end
