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

#import "BRASignInViewController.h"
#import "BRAAgreementViewController.h"
#import "UIViewController+Factory.h"
#import "BRASigninFlow.h"
#import "BRAVisitor.h"
#import "BRASignOutViewController.h"
#import "BRARepository+VisitorAdditions.h"
#import "BRAExpiredObjectsCleaner.h"

@interface BRASignInViewController ()

- (IBAction)signInTapped:(UIButton *)sender;
- (IBAction)signOutTapped:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *leavingLabel;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UILabel *centerLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalHeightLabelConstraint;
@property (assign, nonatomic) CGFloat labelHeight;

@end

@implementation BRASignInViewController

#pragma mark - Class methods

+ (BOOL)shouldPresentSignoutButton {
    BRARepository *repository = [BRARepository sharedInstance];
    return repository.signedInVisitors.count > 0;
}

+ (CGFloat)defaultVerticalHeightLabelConstraint {
    return 280;
}

#pragma mark -

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelHeight = self.verticalHeightLabelConstraint.constant;
    [self setupButtons];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expiredVisitorRemovedNotification:) name:BRAExpiredVisitorsWereRemovedNotificationName object:nil];
}

- (void)setupButtons {
    self.signinButton.layer.cornerRadius = 2;
    self.signoutButton.layer.cornerRadius = 2;
    self.signinButton.exclusiveTouch = YES;
    self.signoutButton.exclusiveTouch = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[BRASigninFlow sharedInstance] startFlow];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateViewState];
}

- (void)updateViewState {
    [UIView animateWithDuration:0.33f
                     animations:^ {
                         if ([[self class] shouldPresentSignoutButton]) {
                             [self showSignoutButton];
                         } else {
                             [self hideSignoutButton];
                         }
                     }];
}

- (void)hideSignoutButton {
    self.verticalHeightLabelConstraint.constant = [[self class] defaultVerticalHeightLabelConstraint];
    self.leavingLabel.hidden = YES;
    self.signoutButton.hidden = YES;
    self.centerLine.hidden = YES;
}

- (void)showSignoutButton {
    self.verticalHeightLabelConstraint.constant = self.labelHeight;
    self.leavingLabel.hidden = NO;
    self.signoutButton.hidden = NO;
    self.centerLine.hidden = NO;
}

#pragma mark - IBActions

- (IBAction)signInTapped:(UIButton *)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    [[BRASigninFlow sharedInstance] currentVisitor].date = [NSDate date];
    [self.navigationController pushViewController:[BRAAgreementViewController bra_controller] animated:YES];
}

- (IBAction)signOutTapped:(UIButton *)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    BRASignOutViewController *signoutViewController = [BRASignOutViewController bra_controller];
    [self.navigationController pushViewController:signoutViewController animated:YES];
}

#pragma mark - Notifications

- (void)expiredVisitorRemovedNotification:(NSNotification *)notification {
    [self updateViewState];
}

@end

