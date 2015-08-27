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

#import "BRAMainViewController.h"
#import "BRASignInViewController.h"
#import "UIViewController+Factory.h"
#import "BRASettingsViewController.h"
#import "BRASettingsManager.h"
#import "BRAAnimator.h"
#import "BRASigninFlow.h"

NSString * const BRAMainViewShouldHideHeaderViewNotification = @"BRAMainViewShouldHideHeaderNotificationViewKey";
NSString * const BRAMainViewShouldShowHeaderViewNotification = @"BRAMainViewShouldShowHeaderNotificationViewKey";

@interface BRAMainViewController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButtonLeft;

@property (strong, nonatomic) NSTimer *clockTimer;

@property (strong, nonatomic) UINavigationController *containerNavigationController;

- (void)doubleTapOnHeader:(UITapGestureRecognizer *)sender;

@end

@implementation BRAMainViewController

- (void)dealloc {
    self.navigationController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_clockTimer invalidate];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signinExpired:) name:BRASigninExpiredNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateHeader:) name:BRAMainViewShouldHideHeaderViewNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateHeader:) name:BRAMainViewShouldShowHeaderViewNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    BRASignInViewController *signInViewController = [BRASignInViewController bra_controller];
    self.containerNavigationController = [[UINavigationController alloc] initWithRootViewController:signInViewController];
    self.containerNavigationController.navigationBarHidden = YES;
    self.containerNavigationController.delegate = self;

    [self addChildViewController:self.containerNavigationController];
    [self.containerView addSubview:self.containerNavigationController.view];
    [self.containerNavigationController didMoveToParentViewController:self];

    [self addConstraintsToContainerNavigationController];
    [self updateCurrentDateLabel];
    self.clockTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    
    [self addTapGestureToHeader];
}

- (void)addTapGestureToHeader {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(doubleTapOnHeader:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.headerView addGestureRecognizer:doubleTap];
}

- (void)addConstraintsToContainerNavigationController {
    UIView *navigationControllerView = self.containerNavigationController.view;
    [navigationControllerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"H:|-0-[navigationControllerView]-0-|"
                                options:NSLayoutFormatDirectionLeadingToTrailing
                                metrics:nil
                                  views:NSDictionaryOfVariableBindings(navigationControllerView)]];
    [self.containerView addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"V:|-0-[navigationControllerView]-0-|"
                                options:NSLayoutFormatDirectionLeadingToTrailing
                                metrics:nil
                                  views:NSDictionaryOfVariableBindings(navigationControllerView)]];
}

- (IBAction)doubleTapOnHeader:(UITapGestureRecognizer *)sender {
    [self showEnterSettingsAlertWithTitle:NSLocalizedString(@"Settings", nil)
                                  message:NSLocalizedString(@"To enter settings, please enter pin", nil)];
}

#pragma mark - Notification

- (void)signinExpired:(NSNotification *)notification {
    [self.containerNavigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Showing Alerts

- (void)showEnterSettingsAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *pinTextField = nil;
    [alertController addTextFieldWithConfigurationHandler:^ (UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Enter pin here", nil);
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        pinTextField = textField;
    }];

    @weakify(self);
    UIAlertAction *enterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Enter", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              @strongify(self);
                                                              if ([pinTextField.text isEqualToString:[[BRASettingsManager sharedInstance] pinCode]]) {
                                                                  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[BRASettingsViewController bra_controller]];
                                                                  [self presentViewController:nc animated:YES completion:nil];
                                                              } else {
                                                                  [self showErrorPinAlert];
                                                              }
                                                          }];
    [alertController addAction:enterAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showErrorPinAlert {
    [self showEnterSettingsAlertWithTitle:NSLocalizedString(@"Incorrect Pin!", nil)
                                  message:NSLocalizedString(@"Please try again", nil)];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    return [BRAAnimator animatorForOperation:operation];
}

#pragma mark - Animation

- (void)animateHeader:(NSNotification *)notification {
    CGFloat newAlpha = 1.0f;
    CGAffineTransform transform = CGAffineTransformIdentity;
    if ([notification.name isEqualToString:BRAMainViewShouldHideHeaderViewNotification]) {
        newAlpha = 0.0f;
        transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0.0f, -CGRectGetMaxY(self.headerView.frame)), CGAffineTransformMakeScale(0.5, 0.5));
    }

    [UIView animateWithDuration:0.33f
                     animations:^ {
                         self.headerView.alpha = newAlpha;
                         self.headerView.transform = transform;
                     }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[BRASignInViewController class]]) {
        self.backButtonLeft.hidden = YES;
    } else {
        self.backButtonLeft.hidden = NO;
    }
}

#pragma mark - Timer actions

- (void)timerTick:(NSTimer *)timerTick {
    [self updateCurrentDateLabel];
}

- (void)updateCurrentDateLabel {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMMM, yyyy, HH:mm"];
    self.dateLabel.text = [[dateFormat stringFromDate:today] uppercaseString];
}

- (IBAction)backButtonLeft:(UIButton *)sender {
    [self.containerNavigationController.topViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.backButtonLeft) {
        return NO;
    }
    return YES;
}

@end
