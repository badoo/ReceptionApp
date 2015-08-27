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

#import "BRAAgreementViewController.h"
#import "BRAFormViewController.h"
#import "UIViewController+Factory.h"
#import "BRASigninFlow.h"
#import "BRAVisitor.h"
#import "BRAWebViewController.h"
#import "FreehandDrawingView.h"

@interface BRAAgreementViewController () <UIWebViewDelegate, FreehandDrawingViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet FreehandDrawingView *freehandDrawingView;

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

- (IBAction)retryTapped:(UIButton *)sender;
- (IBAction)okTapped:(UIButton *)sender;

@property (nonatomic, strong) UIImage *signatureImage;

@end

@implementation BRAAgreementViewController

- (void)dealloc {
    _webView.scrollView.delegate = nil;
    _webView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.freehandDrawingView.delegate = self;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    [self loadAgreementHTML];
    [self enableButtons:NO];
}

- (void)loadAgreementHTML {
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"Agreement"
                                                         ofType:@"html"];
    NSString *agreementHTML = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding
                                                           error:&error];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:agreementHTML baseURL:baseURL];
}

- (BOOL)agreementIsSigned {
    return self.signatureImage != nil;
}

- (void)enableButtons:(BOOL)enable {
    self.retryButton.enabled = enable;
    self.okButton.enabled = enable;
}

#pragma mark - IBActions

- (IBAction)retryTapped:(UIButton *)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    [self.freehandDrawingView removeSignature];
    [self enableButtons:NO];
}

- (IBAction)okTapped:(UIButton *)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    self.signatureImage = self.freehandDrawingView.signatureImage;
    if ([self agreementIsSigned]) {
        [[BRASigninFlow sharedInstance] currentVisitor].signature = self.signatureImage;
        [self.navigationController pushViewController:[BRAFormViewController bra_controller] animated:YES];
    } else {
        [self showErrorAlert];
    }
}

- (void)showErrorAlert {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                message:NSLocalizedString(@"Please sign the agreement first!", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"I understand", nil)
                      otherButtonTitles:nil] show];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *scheme = request.URL.scheme;
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        BRAWebViewController *webController = [BRAWebViewController bra_controller];
        webController.request = request;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webController];
        [self presentViewController:navigationController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView.scrollView flashScrollIndicators];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[BRASigninFlow sharedInstance] registerUserAction];
}

#pragma mark - FreehandDrawingViewDelegate

- (void)freeHandDrawingViewDidFinishDrawing:(FreehandDrawingView *)drawingView {
    [[BRASigninFlow sharedInstance] registerUserAction];
    [self enableButtons:YES];
}

@end
