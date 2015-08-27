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

#import "BRABadgeViewController.h"
#import "BRASigninFlow.h"
#import "BRAVisitor.h"
#import "JMBackgroundCameraView.h"
#import "BRAPrinter.h"
#import "BRAMailManager.h"
#import "BRASettingsManager.h"
#import "BRAMainViewController.h"
#import "UIColor+ComplementaryColors.h"

typedef NS_ENUM(NSUInteger, BRABadgeViewControllerState) {
    BRABadgeViewControllerStateWaitingForPhoto,
    BRABadgeViewControllerStatePhotoCaptured
};

@interface BRABadgeViewController ()
@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *surnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet JMBackgroundCameraView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *cameraViewWrapper;
@property (weak, nonatomic) IBOutlet UILabel *takeAPictureLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeIsReadyLabel;
@property (weak, nonatomic) IBOutlet UIView *VisitorPhotoPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *buttonHolder;
@property (weak, nonatomic) IBOutlet UIButton *makePhotoButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *makePhotoButtonCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *okButtonRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retryButtonLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *badgeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewBottomConstraint;

@property (nonatomic) BRABadgeViewControllerState state;
@property (strong, nonatomic) UIImageView *visitorImageView;

- (IBAction)makePhotoTapped:(UIButton *)sender;
- (IBAction)retryTapped:(id)sender;
- (IBAction)okTapped:(UIButton *)sender;

@end

@implementation BRABadgeViewController

#pragma mark - Constants

+ (CGFloat)constraintDelta {
    return 65.0f;
}

+ (CGFloat)cameraViewWidthExpanded {
    return 400.0f;
}

+ (CGFloat)cameraViewWidthCollapsed {
    return 270.0f;
}

+ (CGFloat)cameraViewConstraintBottom {
    return 232.0f;
}

+ (CGFloat)cameraViewConstraintUp {
    return 670.0f;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = NO;

    self.badgeView.clipsToBounds = NO;
    self.badgeView.layer.borderColor = [[UIColor bra_corporateDarkGray] CGColor];
    self.badgeView.layer.borderWidth = 1.0f;
    self.badgeViewTopConstraint.constant = -168.0f;

    self.state = BRABadgeViewControllerStateWaitingForPhoto;
    self.buttonHolder.alpha = 0;
    self.okButtonRightConstraint.constant = [[self class] constraintDelta];

    [self setupViewWithCurrentVisitor];
    [self setupVisitorImageView];

    [self updateViewStateAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.state = BRABadgeViewControllerStateWaitingForPhoto;
    [self updateViewStateAnimated:YES];
}

- (void)setupViewWithCurrentVisitor {
    BRAVisitor *currentVisitor = [[BRASigninFlow sharedInstance] currentVisitor];
    self.nameLabel.text = [currentVisitor.name capitalizedString];
    self.surnameLabel.text = [currentVisitor.surname capitalizedString];
    self.companyLabel.text = [currentVisitor.company capitalizedString];
    self.dateLabel.text = [self visitDateString:currentVisitor.date];
}

- (NSString *)visitDateString:(NSDate *)visitDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMMM yyyy, HH:mm"];
    return  [[dateFormat stringFromDate:visitDate] uppercaseString];
}

#pragma mark - Animations

- (void)updateViewStateAnimated:(BOOL)animated {
    @weakify(self);
    void (^animations)() = nil;
    void (^completion)(BOOL) = nil;

    if (self.state == BRABadgeViewControllerStateWaitingForPhoto) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BRAMainViewShouldShowHeaderViewNotification object:nil];
        animations = ^ {
            @strongify(self);
            [self setupViewsForWaitingForPhotoState];
            [self.view layoutIfNeeded];
        };
        completion = ^(BOOL finished) {
            [UIView animateWithDuration:0.33
                             animations:^ {
                                 @strongify(self);
                                 self.cameraView.alpha = 1.0f;
                                 self.visitorImageView.alpha = 0.0f;
                             }];
        };
    } else {
        self.visitorImageView.alpha = 1.0f;
        self.cameraView.alpha = 0.0f;
        [[NSNotificationCenter defaultCenter] postNotificationName:BRAMainViewShouldHideHeaderViewNotification object:nil];
        animations = ^ {
            @strongify(self);
            [self setupViewsForPhotoCapturedState];
            [self.view layoutIfNeeded];
        };
        completion = ^(BOOL finished) {
            [UIView animateWithDuration:0.2
                             animations:^ {
                                 @strongify(self);
                                 self.badgeView.alpha = 1.0f;
                             }];
        };
    }

    [UIView animateWithDuration:animated ? 0.33f : 0.0f
                     animations:animations
                     completion:completion];
}

- (void)setupViewsForWaitingForPhotoState {
    self.buttonHolder.alpha = 0;
    self.makePhotoButton.alpha = 1.0f;
    self.makePhotoButtonCenterConstraint.constant = 0;
    self.okButtonRightConstraint.constant = [[self class] constraintDelta];
    self.retryButtonLeftConstraint.constant = [[self class] constraintDelta];
    self.badgeView.alpha = 0.0f;
    self.cameraViewBottomConstraint.constant = [[self class] cameraViewConstraintBottom];
    self.cameraViewWidthConstraint.constant = [[self class] cameraViewWidthExpanded];
    self.takeAPictureLabel.alpha = 1.0f;
    self.badgeIsReadyLabel.alpha = 0.0f;
}

- (void)setupViewsForPhotoCapturedState {
    self.buttonHolder.alpha = 1.0f;
    self.makePhotoButton.alpha = 0;
    self.makePhotoButtonCenterConstraint.constant = -[[self class] constraintDelta];
    self.okButtonRightConstraint.constant = 0;
    self.retryButtonLeftConstraint.constant = 0;
    self.cameraViewBottomConstraint.constant = [[self class] cameraViewConstraintUp];
    self.cameraViewWidthConstraint.constant = [[self class] cameraViewWidthCollapsed];
    self.takeAPictureLabel.alpha = 0.0f;
    self.badgeIsReadyLabel.alpha = 1.0f;
}

#pragma mark - Helpers

- (UIImage *)imageWithView:(UIView *)view insets:(UIEdgeInsets)insets {
    CGRect croppedRect = UIEdgeInsetsInsetRect(view.bounds, insets);
    UIGraphicsBeginImageContextWithOptions(croppedRect.size, view.opaque, 0.0f);

    CGRect rectToDraw = CGRectOffset(view.bounds, -insets.left, -insets.top);
    [view drawViewHierarchyInRect:rectToDraw afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

- (BOOL)canSaveVisitor {
    BOOL canSave = YES;
    NSMutableString *errorMessage = [NSMutableString stringWithString:@""];

    if ([BRAPrinter printer].URL == nil) {
        canSave = NO;
        [errorMessage appendFormat:@"%@ ", NSLocalizedString(@"Printer is not available.", nil)];
    }

    if (![BRAMailManager canSendEmail]) {
        canSave = NO;
        [errorMessage appendFormat:@"%@ ", NSLocalizedString(@"iPad's email is not configured.", nil)];
    }

    if ([[[BRASettingsManager sharedInstance] email] length] == 0) {
        canSave = NO;
        [errorMessage appendFormat:@"%@ ", NSLocalizedString(@"Receiver's email is not configured.", nil)];
    }

    if (!canSave) {
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:errorMessage];
    }

    return canSave;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"I understand", nil)
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)prepareVisitorImageViewForSnapshot {
    [self.VisitorPhotoPlaceholder addSubview:self.visitorImageView];
    self.visitorImageView.frame = self.VisitorPhotoPlaceholder.bounds;
    self.visitorImageView.alpha = 1.0f;
}

#pragma mark - IBActions

- (IBAction)makePhotoTapped:(UIButton *)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    self.state = BRABadgeViewControllerStatePhotoCaptured;
    void (^completionBlock)(UIImage *) = ^(UIImage *image) {
        self.visitorImageView.image = image;
        [self updateViewStateAnimated:YES];
    };

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        completionBlock(nil);
    } else {
        [self.cameraView capturePhotoNowWithCompletionBlock:completionBlock];
    }
}

- (IBAction)retryTapped:(id)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    self.state = BRABadgeViewControllerStateWaitingForPhoto;
    [self updateViewStateAnimated:YES];
}

- (IBAction)okTapped:(UIButton *)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    if ([self canSaveVisitor]) {
        [[BRASigninFlow sharedInstance] currentVisitor].profilePhoto = self.visitorImageView.image;
        [self prepareVisitorImageViewForSnapshot];
        UIImage *imageSnapshot = [self imageWithView:self.badgeView insets:UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f)];
        [[BRASigninFlow sharedInstance] finishFlowWithBadgeImage:imageSnapshot];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Image From camera

- (void)setupVisitorImageView {
    self.visitorImageView = [[UIImageView alloc] initWithFrame:self.cameraView.bounds];
    self.visitorImageView.image = nil;
    self.visitorImageView.backgroundColor = [UIColor clearColor];
    self.visitorImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.visitorImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.visitorImageView.layer.masksToBounds = YES;
    [self.cameraViewWrapper addSubview:self.visitorImageView];
}

@end
