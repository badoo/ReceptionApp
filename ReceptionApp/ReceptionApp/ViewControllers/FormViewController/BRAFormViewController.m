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

#import "BRAFormViewController.h"
#import "BRABadgeViewController.h"
#import "UIViewController+Factory.h"
#import "BRASigninFlow.h"
#import "BRAPerson.h"
#import "BRAVisitor.h"
#import "BRASearchTableViewController.h"
#import "BRASearchEmployeesDataSource.h"
#import "UIColor+ComplementaryColors.h"
#import "NSString+EmailValidity.h"
#import "UITextField+TextInsets.h"

NS_ENUM(NSUInteger , BRAFormFields) {
    BRAFormFieldFullName,
    BRAFormFieldEmail,
    BRAFormFieldCompany,
    BRAFormFieldHereToSee
};

typedef BOOL (^BRAValidationBlock)(NSString *text);

@interface BRAFormViewController () <UITextFieldDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;
@property (nonatomic, weak) IBOutlet UIButton *OkButton;
@property (nonatomic, strong) BRASearchTableViewController *searchTableViewController;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) BRAPerson *hereToSeeEmployee;
@property (nonatomic, strong) NSMapTable *validationRules; // BRAValidationBlock for each textField

- (IBAction)continueTapped:(UIButton *)sender;

@end

@implementation BRAFormViewController

#pragma mark - Class methods

+ (CGSize)popoverSize {
    return CGSizeMake(300, 300);
}

+ (NSInteger)minimumLettersNeededForSearch {
    return 2;
}

+ (NSString *)checkMarkImageNameDataComplete {
    return @"checkAgreement";
}

+ (NSString *)checkMarkImageNameDataIncomplete {
    return @"checkGray";
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hereToSeeEmployee = [[BRASigninFlow sharedInstance] currentVisitor].employee;
    [self setupTextFields];
    [self updateUIWithCurrentVisitor];
    [self addTargetsToTextFields];
    [self setupValidationRules];
    [self changeOKButtonIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.popover dismissPopoverAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITextField *textFieldToSelect = self.textFields[BRAFormFieldFullName];
    [self selectTextField:textFieldToSelect];
}

- (void)dealloc {
    _popover.delegate = nil;
}

#pragma mark - private api

- (void)setupTextFields {
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
        textField.exclusiveTouch = YES;
        textField.layer.borderWidth = 1.0f;
        textField.layer.borderColor = [[UIColor bra_corporateDarkGray] CGColor];
        textField.layer.cornerRadius = 4;
        [textField bra_insetTextByPoints:14];
    }
}

- (void)updateUIWithCurrentVisitor {
    BRAVisitor *currentVisitor = [[BRASigninFlow sharedInstance] currentVisitor];
    if (currentVisitor) {
        UITextField *nameTextField = self.textFields[BRAFormFieldFullName];
        nameTextField.text = currentVisitor.nameAndSurname;
        UITextField *emailTextField = self.textFields[BRAFormFieldEmail];
        emailTextField.text = currentVisitor.email;
        UITextField *companyTextField = self.textFields[BRAFormFieldCompany];
        companyTextField.text = currentVisitor.company;
        UITextField *hereToSeeTextField = self.textFields[BRAFormFieldHereToSee];
        hereToSeeTextField.text = [currentVisitor.employee nameAndSurname];
    }
}

- (void)setupValidationRules {
    BRAValidationBlock nameValidation = ^BOOL(NSString *text) {
        NSArray *names = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        names = [names filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        return ([text length] >= 4) && ([names count] >= 2);
    };
    BRAValidationBlock emailValidation = ^BOOL(NSString *text) {
        return [text bra_isValidEmailAddress];
    };
    BRAValidationBlock companyValidation = ^BOOL(NSString *text) {
        return [text length] >= 2;
    };
    BRAValidationBlock employeeValidation = ^BOOL(NSString *text) {
        return self.hereToSeeEmployee != nil;
    };

    self.validationRules = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
    [self.validationRules setObject:[nameValidation copy] forKey:self.textFields[BRAFormFieldFullName]];
    [self.validationRules setObject:[emailValidation copy] forKey:self.textFields[BRAFormFieldEmail]];
    [self.validationRules setObject:[companyValidation copy] forKey:self.textFields[BRAFormFieldCompany]];
    [self.validationRules setObject:[employeeValidation copy] forKey:self.textFields[BRAFormFieldHereToSee]];
}

- (void)addTargetsToTextFields {
    for (UITextField *textField in [self textFields]) {
        [textField addTarget:self
                      action:@selector(textFieldDidChanged:)
            forControlEvents:UIControlEventEditingChanged];
    }
}

- (void)selectTextField:(UITextField *)textFieldToSelect {
    textFieldToSelect.layer.borderColor = [[UIColor bra_corporateBlue] CGColor];
    [textFieldToSelect becomeFirstResponder];
}

- (void)deselectedTextField:(UITextField *)textFieldDeselected{
    textFieldDeselected.layer.borderColor = [[UIColor bra_corporateDarkGray] CGColor];
    [textFieldDeselected resignFirstResponder];
}

- (void)updateValidationStateOfTextField:(UITextField *)textField {
    BRAValidationBlock validationRule = [self.validationRules objectForKey:textField];
    if (validationRule && !validationRule(textField.text)) {
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
}

#pragma mark - IBActions

- (IBAction)continueTapped:(UIButton *)sender {
    [[BRASigninFlow sharedInstance] registerUserAction];
    if ([self dataIsComplete]) {
        [self updateCurrentUser];
        [self.navigationController pushViewController:[BRABadgeViewController bra_controller] animated:YES];
    } else {
        for (UITextField *textField in [self textFields]) {
            [self updateValidationStateOfTextField:textField];
        }
    }
}

#pragma mark - Extracting data

- (NSString *)fullName {
    UITextField *textField = self.textFields[BRAFormFieldFullName];
    return textField.text;
}

- (NSString *)email {
    UITextField *textField = self.textFields[BRAFormFieldEmail];
    return textField.text;
}

- (NSString *)company {
    UITextField *textField = self.textFields[BRAFormFieldCompany];
    return textField.text;
}

#pragma mark - Private methods

- (void)updateCurrentUser {
    BRAVisitor *currentVisitor = [[BRASigninFlow sharedInstance] currentVisitor];
    currentVisitor.name = [self visitorFirstName];
    currentVisitor.surname = [self visitorLastName];
    currentVisitor.email = [self email];
    currentVisitor.company = [self company];
    currentVisitor.employee = self.hereToSeeEmployee;
}

- (NSString *)visitorFirstName {
    NSArray *names = [[self fullName] componentsSeparatedByString:@" "];
    NSString *firstName = nil;
    if ([names count]) {
        firstName = names[0];
    }
    return firstName;
}

- (NSString *)visitorLastName {
    NSArray *names = [[self fullName] componentsSeparatedByString:@" "];
    NSString *lastName = nil;
    if ([names count] > 1) {
        NSString *firstName = names[0];
        lastName = [[self fullName] substringWithRange:NSMakeRange([firstName length] + 1, [[self fullName] length] - [firstName length] - 1)];
    }
    return lastName;
}

- (BOOL)dataIsComplete {
    for (UITextField *textField in self.textFields) {
        BRAValidationBlock validationRule = [self.validationRules objectForKey:textField];
        if (validationRule && !validationRule(textField.text)) {
            return NO;
        }
    }
    return YES;
}

- (NSUInteger)indexOfTextField:(UITextField *)textField {
    for (NSUInteger i = 0; i < [self.textFields count]; ++i) {
        UITextField *field = self.textFields[i];
        if (textField == field) {
            return i;
        }
    }
    return 0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSUInteger indexOfTextField = [self indexOfTextField:textField];
    if (indexOfTextField == [self.textFields count] - 1) {
        [self continueTapped:nil];
    } else {
        UITextField *nextTextField = self.textFields[indexOfTextField + 1];
        [self selectTextField:nextTextField];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [[BRASigninFlow sharedInstance] registerUserAction];
    [self selectTextField:textField];
    if (textField == self.textFields[BRAFormFieldHereToSee]) {
        @weakify(self, textField);
        self.searchTableViewController = [[BRASearchTableViewController alloc] initWithCompletionBlock:^(BRAPerson *person) {
            @strongify(self, textField);
            textField.text = person.nameAndSurname;
            self.hereToSeeEmployee = person;
            [self.popover dismissPopoverAnimated:YES];
            [self updateValidationStateOfTextField:textField];
            [self changeOKButtonIfNeeded];
        }];

        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.searchTableViewController];
        self.popover.backgroundColor = [UIColor whiteColor];
        self.popover.delegate = self;
        self.searchTableViewController.preferredContentSize = [[self class] popoverSize];
        self.searchTableViewController.searchDataSource = [BRASearchEmployeesDataSource new];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "] && textField.text.length == 0  ) {
        return NO;
    }
    if (range.location == 0 && range.length == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    if ([textField.text hasSuffix:@" "] && [string isEqualToString:@" "]) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.textFields[BRAFormFieldHereToSee]) {
        return self.hereToSeeEmployee != nil || textField.text.length < 2;
    }

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self deselectedTextField:textField];
    [self updateValidationStateOfTextField:textField];
}

- (void)textFieldDidChanged:(UITextField *)textField {
    [[BRASigninFlow sharedInstance] registerUserAction];
    [self selectTextField:textField];
    if (textField == self.textFields[BRAFormFieldHereToSee]) {
        self.hereToSeeEmployee = nil;
        if (textField.text.length >= [[self class] minimumLettersNeededForSearch]) {
            [self presentPopoverWithTextField:textField];
            [self.searchTableViewController nameDidChange:textField.text];
        } else if (textField.text.length == [[self class] minimumLettersNeededForSearch] - 1) {
            [self.popover dismissPopoverAnimated:YES];
        }
    }

    [self changeOKButtonIfNeeded];
}

#pragma mark - Present Popover

- (void)presentPopoverWithTextField:(UITextField *)textField {
    if (![self.popover isPopoverVisible]) {
        [self.popover presentPopoverFromRect:textField.frame
                                      inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionLeft
                                    animated:true];
    }
}

#pragma mark - PopoverController Delegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return NO;
}

#pragma mark - Button Color Animation

- (void)changeOKButtonIfNeeded {
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^ {
        @strongify(self);
        NSString *imageName = [self dataIsComplete] ? [[self class] checkMarkImageNameDataComplete] : [[self class] checkMarkImageNameDataIncomplete];
        [self.OkButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        self.OkButton.enabled = [self dataIsComplete];
    }];
}

@end
