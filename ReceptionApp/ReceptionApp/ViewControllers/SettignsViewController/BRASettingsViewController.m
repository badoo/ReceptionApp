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

#import "BRASettingsViewController.h"
#import "BRASettingsManager.h"
#import "BRAPrinterController.h"
#import "BRAPrinter.h"
#import "BRAMailManager.h"
#import "BRARepository.h"
#import "BRARepository+VisitorAdditions.h"
#import "NSString+EmailValidity.h"

@interface BRASettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pinTextField;
@property (weak, nonatomic) IBOutlet UITextField *devEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *printerTextField;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *SMTPTextField;

@property (nonatomic, strong) UIPrinter *printer;

- (IBAction)sendSignedInReport:(UIButton *)sender;

@end

@implementation BRASettingsViewController

- (void)dealloc {
    [self setupTextFieldsDelegate:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", nil);
    [self setupNavBarItems];
    [self setupTextFields];
    self.printer = [BRAPrinter printer];
}

- (void)setupNavBarItems {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(save:)];
}

- (void)setupTextFields {
    self.emailTextField.text = [[BRASettingsManager sharedInstance] email];
    self.devEmailTextField.text = [[BRASettingsManager sharedInstance] devEmail];
    self.pinTextField.text = [[BRASettingsManager sharedInstance] pinCode];
    self.versionLabel.text = [[BRASettingsManager sharedInstance] currentAppVersion];
    self.printerTextField.text = [[BRASettingsManager sharedInstance] printerName];
    self.accountTextField.text = [[BRASettingsManager sharedInstance] accountToSendEmail];
    self.passwordTextField.text = [[BRASettingsManager sharedInstance] accountPassword];
    self.portTextField.text = [[BRASettingsManager sharedInstance] portSMTP];
    self.SMTPTextField.text = [[BRASettingsManager sharedInstance] SMTPServer];

    [self setupTextFieldsDelegate:self];
}

- (void)setupTextFieldsDelegate:(id <UITextFieldDelegate>)delegate {
    self.emailTextField.delegate = delegate;
    self.devEmailTextField.delegate = delegate;
    self.pinTextField.delegate = delegate;
    self.printerTextField.delegate = delegate;
    self.SMTPTextField.delegate = delegate;
    self.portTextField.delegate = delegate;
    self.passwordTextField.delegate = delegate;
    self.accountTextField.delegate = delegate;
}

- (void)setupPrintersView {
    UIPrinterPickerController *printerPicker = [BRAPrinterController printerPickerController];
    [printerPicker presentFromRect:self.printerTextField.bounds
                            inView:self.printerTextField
                          animated:YES
                 completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error) {
                     if (![printerPickerController.selectedPrinter.URL isEqual:self.printer.URL]) {
                         self.printer = printerPickerController.selectedPrinter;
                         self.printerTextField.text = printerPickerController.selectedPrinter.displayName;
                     }
                     [printerPicker dismissAnimated:YES];
                 }];
}

#pragma mark - Actions

- (void)cancel:(UIBarButtonItem *)barButton {
    [self dismiss];
}

- (void)save:(UIBarButtonItem *)barButton {
    if ([self verifyInputData]) {
        [self readTextFields];
        [BRAPrinter savePrinterURL:self.printer.URL];
        [self dismiss];
    }
}

- (void)readTextFields {
    [[BRASettingsManager sharedInstance] setEmail:self.emailTextField.text];
    [[BRASettingsManager sharedInstance] setDevEmail:self.devEmailTextField.text];
    [[BRASettingsManager sharedInstance] setPinCode:self.pinTextField.text];
    [[BRASettingsManager sharedInstance] setPrinterName:self.printerTextField.text];
    [[BRASettingsManager sharedInstance] setAccountPassword:self.passwordTextField.text];
    [[BRASettingsManager sharedInstance] setPortSMTP:self.portTextField.text];
    [[BRASettingsManager sharedInstance] setAccountToSendEmail:self.accountTextField.text];
    [[BRASettingsManager sharedInstance] setSMTPServer:self.SMTPTextField.text];
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendSignedInReport:(UIButton *)sender {
    NSArray *visitors = [[BRARepository sharedInstance] signedInVisitors];
    [BRAMailManager sendSignInReportWithVisitors:visitors];
}

#pragma mark - Helpers

- (NSArray *)splitMails {
    NSString *emailsText = [self.emailTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *mails = [emailsText componentsSeparatedByString:@","];
    return mails;
}

- (BOOL)verifyInputData {
    if (![self emailsAreValid]) {
        [self showErrorWithMessage:NSLocalizedString(@"Email is not valid!", nil)];
        [self.emailTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self pinIsValid]) {
        [self showErrorWithMessage:NSLocalizedString(@"Pin is not valid!", nil)];
        [self.pinTextField becomeFirstResponder];
        return NO;
    }
    
    if (!self.printer) {
        [self showErrorWithMessage:NSLocalizedString(@"Need a printer", nil)];
        return NO;
    }
    
    return YES;
}

- (BOOL)pinIsValid {
    NSString *pin = self.pinTextField.text;
    return [pin length] > 3;
}

- (BOOL)emailsAreValid {
    BOOL emailsValid = NO;
    
    for (NSString *email in [self splitMails]) {
        emailsValid = [email bra_isValidEmailAddress];
        if (!emailsValid) {
            break;
        }
    }
    
    BOOL devEmailIsValid = [self.devEmailTextField.text length] == 0 || [self.devEmailTextField.text bra_isValidEmailAddress];
    return devEmailIsValid && emailsValid;
}

- (void)showErrorWithMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"I understand", nil)
                      otherButtonTitles:nil] show];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.printerTextField) {
        [self setupPrintersView];
        return NO;
    }
    return YES;
}

@end
