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

#import "BRASignOutViewController.h"
#import "BRASignoutCollectionDatasource.h"
#import "BRASignoutCollectionCell.h"
#import "BRAVisitorSelectedFlowLayout.h"
#import "BRAVisitor.h"
#import "BRAMailManager.h"
#import "BRASigninFlow.h"

typedef NS_ENUM(NSUInteger, BRASignoutViewControllerState) {
    BRASignoutViewControllerStateInitial,
    BRASignoutViewControllerStatePhotoSelected
};

@interface BRASignOutViewController () <UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) BRASignoutCollectionDataSource *collectionDataSource;
@property (nonatomic, assign) BRASignoutViewControllerState state;
@property (nonatomic, strong) BRAVisitorSelectedFlowLayout *selectedFlowLayout;
@property (nonatomic, strong) BRASelectNamesView *buttonsView;
@property (nonatomic, strong) BRAVisitor *selectedVisitor;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation BRASignOutViewController

+ (NSString *)cellIdentifier {
    return @"CellIdentifier";
}

+ (NSString *)textForInitialState {
    return NSLocalizedString(@"Sign Out:", nil);
}

+ (NSString *)textForPhotoSelectedState {
    return NSLocalizedString(@"What's your name?", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionDataSource = [BRASignoutCollectionDataSource new];
    [self setupCollectionView];

    if ([self.collectionDataSource numberOfVisitors] == 1) {
        self.state = BRASignoutViewControllerStatePhotoSelected;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        self.selectedVisitor = [self.collectionDataSource visitorAtIndex:indexPath.row];
        self.collectionView.collectionViewLayout = [[BRAVisitorSelectedFlowLayout alloc] initWithRowSelectedIndexPath:indexPath];
        self.titleLabel.text = [[self class] textForPhotoSelectedState];
        [self setupButtonsView];
    }
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self.collectionDataSource;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[BRASignoutCollectionCell class] forCellWithReuseIdentifier:[[self class] cellIdentifier]];
    self.collectionView.clipsToBounds = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
}

#pragma mark - Actions

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CollectionView change state

- (void)updateViewStateAtIndexPath:(NSIndexPath *)indexPath {
    if (self.state == BRASignoutViewControllerStateInitial) {
        [self.collectionView setCollectionViewLayout:[[BRAVisitorSelectedFlowLayout alloc] initWithRowSelectedIndexPath:indexPath]
                                            animated:YES
                                          completion:^(BOOL finished) {
                                              [self setupButtonsView];
                                               self.titleLabel.text = [[self class] textForPhotoSelectedState];
                                          }];
       
    } else {
        [self.buttonsView removeFromSuperview];
        [self.collectionView setCollectionViewLayout:[UICollectionViewFlowLayout new]
                                            animated:YES];
        self.titleLabel.text = [[self class] textForInitialState];
    }
    self.currentIndexPath = indexPath;
    self.state = !self.state;
}

#pragma mark - FlowLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [BRAVisitorSelectedFlowLayout cellSize];
}

#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[BRASigninFlow sharedInstance] registerUserAction];
    self.selectedVisitor = [self.collectionDataSource visitorAtIndex:indexPath.row];
    [self updateViewStateAtIndexPath:indexPath];
}

#pragma mark - Buttons Name View

- (void)setupButtonsView {
    self.buttonsView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BRASelectNamesView class])
                                                     owner:self
                                                   options:nil][0];
    self.buttonsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonsView.nameAndSurname = self.selectedVisitor.nameAndSurname;
    self.buttonsView.delegate = self;
    [self.view insertSubview:self.buttonsView aboveSubview:self.collectionView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonsView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonsView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:70]];
}

#pragma mark - Mail Actions

- (void)sendSignedOutMail {
    [BRAMailManager sendSignedOutEmailWithVisitor:self.selectedVisitor];
}

#pragma mark - Buttons Name View Delegate

- (void)nameDidSelected:(NSString *)name {
    [[BRASigninFlow sharedInstance] registerUserAction];
    if ([name isEqualToString:self.selectedVisitor.nameAndSurname]) {
        [self.collectionDataSource removeVisitorAtIndexPath:self.currentIndexPath];
        [self sendSignedOutMail];
        [self goBack];
    } else if ([self.collectionDataSource numberOfVisitors] == 1) {
        [self goBack];
    } else {
        [self updateViewStateAtIndexPath:self.currentIndexPath];
    }
}

@end
