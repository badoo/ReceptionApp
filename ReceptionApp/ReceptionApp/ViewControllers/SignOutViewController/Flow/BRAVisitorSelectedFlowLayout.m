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

#import "BRAVisitorSelectedFlowLayout.h"

@interface BRAVisitorSelectedFlowLayout ()
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation BRAVisitorSelectedFlowLayout

+ (CGSize)cellSize {
    return CGSizeMake(154, 154);
}

- (instancetype)initWithRowSelectedIndexPath:(NSIndexPath *)indexPath {
    if (self = [super init]) {
        _indexPath = indexPath;
    }
    return self;
}
- (NSInteger)numberOfCellsInSection:(NSInteger)section {
    return [self.collectionView numberOfItemsInSection:section];
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.contentSize.width, [self itemSize].height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray new];
    for (int j = 0; j < [self numberOfCellsInSection:0]; j++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.center = [self centerWithIndexPath:indexPath];
    attributes.size = [[self class] cellSize];
    attributes.alpha = indexPath.row != self.indexPath.row ? 0 : 1;
    return attributes;
}

- (CGPoint)initialCenterWithIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].center;
}

- (CGPoint)centerWithIndexPath:(NSIndexPath *)indexPath {
    CGPoint center;
    if (indexPath.row != self.indexPath.row) {
        CGPoint initialCenter = [self initialCenterWithIndexPath:indexPath];
        center = CGPointMake(initialCenter.x, CGRectGetHeight(self.collectionView.frame) + [[self class] cellSize].height);
    } else {
        center = CGPointMake(CGRectGetWidth(self.collectionView.bounds)/2, [[self class] cellSize].height/2);
    }
        
    return center;
}

@end
