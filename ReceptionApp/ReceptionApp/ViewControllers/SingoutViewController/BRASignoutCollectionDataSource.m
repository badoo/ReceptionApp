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

#import "BRASignoutCollectionDataSource.h"
#import "BRASignOutViewController.h"
#import "BRARepository+VisitorAdditions.h"
#import "BRASignoutCollectionCell.h"

@interface BRASignoutCollectionDataSource ()

@property (nonatomic, strong) BRARepository *visitorRepository;
@property (nonatomic, strong) NSArray *visitors;

@end

@implementation BRASignoutCollectionDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.visitorRepository = [BRARepository sharedInstance];
        [self reloadVisitors];
    }    
    return self;
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.visitors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BRASignoutCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BRASignOutViewController cellIdentifier] forIndexPath:indexPath];
    cell.cellImage = [self.visitors[(NSUInteger) indexPath.row] profilePhoto];
    return cell;
}

#pragma mark - private api

- (void)reloadVisitors {
    self.visitors = self.visitorRepository.signedInVisitors;
}

#pragma mark - public api

- (NSUInteger)numberOfVisitors {
    return [self.visitors count];
}

- (BRAVisitor *)visitorAtIndex:(NSInteger)index {
    return self.visitors[(NSUInteger) index];
}

- (void)removeVisitorAtIndexPath:(NSIndexPath *)indexPath {
    [self.visitorRepository deleteVisitor:self.visitors[(NSUInteger) indexPath.row]];
    [self reloadVisitors];
    
}
@end
